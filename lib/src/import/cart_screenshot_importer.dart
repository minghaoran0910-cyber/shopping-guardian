import 'package:flutter/services.dart';

import 'share_parser.dart';

class CartScreenshotImporter {
  const CartScreenshotImporter({this.channel = const MethodChannel(_channel)});

  static const _channel = 'shopping_guardian/cart_ocr';
  final MethodChannel channel;

  Future<List<SharedShoppingItem>> pickAndRecognize() async {
    return (await pickAndRecognizeDetailed()).items;
  }

  Future<ScreenshotImportResult> pickAndRecognizeDetailed() async {
    final raw = await channel.invokeListMethod<String>('pickAndRecognize');
    if (raw == null) return const ScreenshotImportResult.cancelled();
    return ScreenshotImportResult(
      items: CartScreenshotParser.parse(raw),
      recognizedLineCount: raw.where((line) => line.trim().isNotEmpty).length,
    );
  }
}

class ScreenshotImportResult {
  const ScreenshotImportResult({
    required this.items,
    required this.recognizedLineCount,
    this.wasCancelled = false,
  });

  const ScreenshotImportResult.cancelled()
    : items = const [],
      recognizedLineCount = 0,
      wasCancelled = true;

  final List<SharedShoppingItem> items;
  final int recognizedLineCount;
  final bool wasCancelled;
}

abstract final class CartScreenshotParser {
  static final _pricePattern = RegExp(
    r'(?:[¥￥Yy$*]|RMB)\s*(\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  static final _barePricePattern = RegExp(r'^\s*(\d{2,7}(?:\.\d{1,2})?)\s*$');
  static final _quantityPattern = RegExp(r'[xX×]\s*(\d+)');

  static List<SharedShoppingItem> parse(List<String> lines) {
    final platform = _platform(lines);
    if (_looksLikeProductDetail(lines)) {
      final detail = platform == ShoppingPlatform.pinduoduo
          ? _parsePinduoduoDetail(lines)
          : _parseProductDetail(lines, platform);
      if (detail != null) return [detail];
    }

    final items = <SharedShoppingItem>[];
    final candidates = <String>[];
    double? pendingPrice;
    var previousPriceWasPaired = false;

    for (final source in lines) {
      final line = source.trim();
      if (line.isEmpty || _ignored(line)) continue;

      final prices = _prices(line);
      if (_shop(line)) {
        if (pendingPrice == null) candidates.clear();
        previousPriceWasPaired = false;
        continue;
      }
      if (prices.isEmpty) {
        previousPriceWasPaired = false;
        final candidate = _cleanCartCandidate(line);
        if (candidate != null) {
          candidates.add(candidate);
        }
        continue;
      }

      if (pendingPrice != null) {
        final pendingTitle = _bestTitle(candidates);
        if (pendingTitle != null) {
          _addItem(items, platform, pendingTitle, pendingPrice);
        }
        pendingPrice = null;
        candidates.clear();
      }

      final title = _bestTitle(candidates);
      candidates.clear();
      final price = prices.first;
      if (title == null) {
        if (previousPriceWasPaired) {
          previousPriceWasPaired = false;
          continue;
        }
        pendingPrice = price;
        continue;
      }
      final quantity = _quantityPattern.firstMatch(line)?.group(1);
      _addItem(
        items,
        platform,
        title,
        price,
        quantity: int.tryParse(quantity ?? '') ?? 1,
      );
      previousPriceWasPaired = true;
    }
    if (pendingPrice != null) {
      final title = _bestTitle(candidates);
      if (title != null) _addItem(items, platform, title, pendingPrice);
    }
    return items;
  }

  static void _addItem(
    List<SharedShoppingItem> items,
    ShoppingPlatform platform,
    String title,
    double price, {
    int quantity = 1,
  }) {
    items.add(
      SharedShoppingItem(
        platform: platform,
        kind: ShareKind.product,
        url: Uri.parse('local://cart-screenshot/${items.length + 1}'),
        title: title,
        price: price,
        quantity: quantity,
      ),
    );
  }

  static bool _looksLikeProductDetail(List<String> lines) {
    final text = _compact(lines.join());
    final hasCartCheckout = lines.any((line) {
      final compact = _compact(line);
      return compact == '结算' ||
          compact.startsWith('去结算') ||
          compact.startsWith('合计');
    });
    if (hasCartCheckout) return false;
    final hasSales = _salesMarker(text);
    final hasPurchaseAction =
        text.contains('加入购物车') ||
        text.contains('立即购买') ||
        text.contains('马上购买') ||
        text.contains('领券购买') ||
        text.contains('去购买') ||
        text.contains('免拼购买') ||
        text.contains('直接拼成');
    return hasSales || hasPurchaseAction;
  }

  static SharedShoppingItem? _parsePinduoduoDetail(List<String> source) {
    final lines = source.map((line) => line.trim()).toList();
    final selectedPrice = _selectDetailPrice(lines);
    if (selectedPrice == null) return null;

    final titleStarts = <String>[];
    final titleEnds = <String>[];
    for (var index = 0; index < lines.length; index++) {
      final source = lines[index];
      final compact = _compact(source);
      final containsTitleSuffix = compact.contains('退货包运费');
      final containsPromoTitle =
          compact.startsWith('季末优惠') || compact.startsWith('季未优惠');
      final standalonePromo = compact == '季末优惠' || compact == '季未优惠';
      if (standalonePromo && index + 1 < lines.length) {
        final next = lines[index + 1].trim();
        if (next.length >= 10 && _titleCandidate(next)) titleStarts.add(next);
        continue;
      }
      if (!containsTitleSuffix && !containsPromoTitle) continue;
      final line = source
          .replaceFirst(RegExp(r'^店铺\s*收藏\s*客服.*?品牌\s*'), '')
          .replaceAll('退货包运费', '')
          .replaceFirst(RegExp(r'^[\]］】\s]+'), '')
          .replaceFirst(RegExp(r'^季[末未]优惠\s*'), '')
          .replaceAll('|', '')
          .trim();
      if (line.length >= 6 &&
          !RegExp(r'^[·•\d]').hasMatch(line) &&
          !_detailNoise(line) &&
          _titleCandidate(line)) {
        (containsPromoTitle ? titleStarts : titleEnds).add(line);
      }
    }
    var titleParts = [...titleStarts, ...titleEnds];
    if (titleParts.isEmpty) {
      final candidates = <({int index, String line})>[];
      for (var index = 0; index < lines.length; index++) {
        final cleaned = lines[index]
            .replaceFirst(RegExp(r'^店铺\s*收藏\s*客服.*?品牌\s*'), '')
            .replaceFirst(RegExp(r'^(?:百亿补贴\s*)?品牌\s*'), '')
            .replaceAll('退货包运费', '')
            .trim();
        if (_pinduoduoNoise(cleaned) ||
            _detailNoise(cleaned) ||
            _promotionOnly(cleaned) ||
            _prices(cleaned).isNotEmpty ||
            !_titleCandidate(cleaned)) {
          continue;
        }
        candidates.add((index: index, line: cleaned));
      }
      if (candidates.isEmpty) return null;
      titleParts = _bestTitleRun(candidates);
    }
    final title = _stripPinduoduoNavigationPrefix(titleParts.join().trim());
    if (title.isEmpty) return null;
    if (title.length < 4) return null;
    return SharedShoppingItem(
      platform: ShoppingPlatform.pinduoduo,
      kind: ShareKind.product,
      url: Uri.parse('local://product-screenshot/1'),
      title: title,
      price: selectedPrice.price,
    );
  }

  static SharedShoppingItem? _parseProductDetail(
    List<String> source,
    ShoppingPlatform platform,
  ) {
    final lines = source.map((line) => line.trim()).toList();
    var selectedPrice = _selectDetailPrice(lines);
    // Some Android OCR engines omit the currency sign and return text blocks
    // out of visual order. This branch only runs after the page has already
    // been identified as a product detail, so a standalone amount is safe to
    // consider anywhere before the store/service metadata.
    if (selectedPrice == null) {
      for (var index = 0; index < lines.length; index++) {
        if (_detailNoise(lines[index])) break;
        final bare = _barePricePattern.firstMatch(lines[index]);
        final price = double.tryParse(bare?.group(1) ?? '');
        if (price != null && price >= 10) {
          selectedPrice = (price: price, index: index);
          break;
        }
      }
    }
    if (selectedPrice == null) return null;

    final candidates = <({int index, String line, bool branded})>[];
    for (var index = 0; index < lines.length; index++) {
      final source = lines[index];
      final compact = _compact(source);
      final hasBrandPrefix = RegExp(r'^(?:天猫|民猫|自营|自當|极有家)').hasMatch(compact);
      final cleaned = source
          .replaceFirst(RegExp(r'^(?:天猫|民猫|自营|自當|极有家)\s*'), '')
          .trim();
      if (_detailNoise(cleaned) ||
          _promotionOnly(cleaned) ||
          _prices(cleaned).isNotEmpty ||
          !_titleCandidate(cleaned)) {
        continue;
      }
      // Short but valid names are common in test fixtures and real listings
      // such as accessories or model-only titles. Noise has already been
      // removed above, so keep every normal title candidate here.
      if (cleaned.length >= 4) {
        candidates.add((index: index, line: cleaned, branded: hasBrandPrefix));
      }
    }
    final branded = candidates.where((candidate) => candidate.branded).toList();
    if (branded.isNotEmpty) {
      final anchor = branded.reduce(
        (best, candidate) =>
            _titleScore(candidate.line) > _titleScore(best.line)
            ? candidate
            : best,
      );
      final titleParts = _adjacentTitleParts(
        (index: anchor.index, line: anchor.line),
        candidates
            .map((candidate) => (index: candidate.index, line: candidate.line))
            .toList(),
      );
      final title = titleParts.join(' ').trim();
      return SharedShoppingItem(
        platform: platform,
        kind: ShareKind.product,
        url: Uri.parse('local://product-screenshot/1'),
        title: title,
        price: selectedPrice.price,
      );
    }

    // Vision and ML Kit do not guarantee the same block order. In particular,
    // iOS may place a repeated bottom-bar price after the real product title.
    // The candidates above are already filtered, so rank the whole page rather
    // than assuming the title follows whichever price won the price scoring.
    final genericCandidates = candidates
        .map((candidate) => (index: candidate.index, line: candidate.line))
        .toList();
    if (genericCandidates.isEmpty) return null;
    final titleParts = _bestTitleRun(genericCandidates);
    final title = titleParts.join(' ').trim();
    if (title.length < 4) return null;

    return SharedShoppingItem(
      platform: platform,
      kind: ShareKind.product,
      url: Uri.parse('local://product-screenshot/1'),
      title: title,
      price: selectedPrice.price,
    );
  }

  static ({double price, int index})? _selectDetailPrice(List<String> lines) {
    ({double price, int index, int score})? best;
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (_detailNoise(line)) continue;
      final prices = _prices(line);
      if (prices.isEmpty) continue;
      final compact = _compact(line);
      var score = 10;
      if (RegExp(
        r'券后|大促价|秒杀价|店铺优惠后|平台加补后|加补后|补贴后|补贴价|政府补贴价|到手价',
      ).hasMatch(compact)) {
        score += 100;
      }
      if (compact.contains('预估')) score -= 70;
      if (RegExp(r'省\d|减\d|优惠\d+元').hasMatch(compact) &&
          !RegExp(r'券后|加补后|补贴后|补贴价|到手价').hasMatch(compact)) {
        score -= 60;
      }
      if (best == null || score > best.score) {
        best = (price: prices.first, index: index, score: score);
      }
    }
    if (best == null) return null;
    return (price: best.price, index: best.index);
  }

  static List<String> _adjacentTitleParts(
    ({int index, String line}) anchor,
    List<({int index, String line})> candidates,
  ) {
    final after = candidates
        .where((candidate) => candidate.index == anchor.index + 1)
        .firstOrNull;
    final parts = <String>[anchor.line];
    if (after != null && after.line.length >= 4) parts.add(after.line);
    return parts;
  }

  static List<String> _bestTitleRun(
    List<({int index, String line})> candidates,
  ) {
    var best = <({int index, String line})>[];
    var current = <({int index, String line})>[];
    var bestScore = -1;
    void considerCurrent() {
      final score = current.fold<int>(
        0,
        (total, candidate) => total + _titleScore(candidate.line),
      );
      if (score > bestScore) {
        bestScore = score;
        best = [...current];
      }
    }

    for (final candidate in candidates) {
      if (current.isNotEmpty && candidate.index != current.last.index + 1) {
        considerCurrent();
        current = [];
      }
      current.add(candidate);
      if (current.length == 3) {
        considerCurrent();
        current = [];
      }
    }
    if (current.isNotEmpty) considerCurrent();
    return best.map((candidate) => candidate.line).toList();
  }

  static bool _pinduoduoNoise(String line) {
    final compact = _compact(line);
    return compact.startsWith('品牌') ||
        compact.contains('官方旗舰') ||
        compact.contains('品牌放心购') ||
        compact.contains('先用后付') ||
        compact.contains('无需等待') ||
        compact.contains('拼单即将结束') ||
        compact.contains('对比后下单') ||
        compact.contains('人好评') ||
        compact.contains('人收藏') ||
        compact.contains('人买过') ||
        compact.contains('全店') ||
        compact.contains('周销量') ||
        compact.contains('近30天') ||
        compact.contains('近15天') ||
        compact.contains('近7天') ||
        compact.contains('同类畅销') ||
        compact.contains('正品保障');
  }

  static String _stripPinduoduoNavigationPrefix(String title) {
    return title
        .replaceFirst(
          RegExp(r'^店铺\s*(?:收藏\s*)?(?:客服\s*)?.{0,12}?品牌\s*'),
          '',
        )
        .trim();
  }

  static bool _detailNoise(String line) =>
      _compact(line).contains('送礼') ||
      _compact(line) == '京东超市' ||
      _compact(line).endsWith('旗舰店') ||
      _compact(line).contains('店铺评分') ||
      _compact(line).contains('回头客') ||
      _compact(line).contains('发货') ||
      _compact(line).contains('送达') ||
      _compact(line).contains('快递') ||
      _compact(line).contains('无理由退货') ||
      _compact(line).contains('极速退款') ||
      _compact(line).contains('亮点总结') ||
      _compact(line).contains('进一步了解') ||
      _compact(line).contains('细节把控') ||
      _compact(line).contains('KB/s') ||
      _compact(line).contains('MB/s') ||
      _compact(line).contains('可再享') ||
      _compact(line).contains('小金库') ||
      _compact(line).contains('白条') ||
      _compact(line).contains('人浏览') ||
      _compact(line).contains('热卖榜') ||
      _compact(line).contains('加入购物车') ||
      _compact(line).contains('立即购买') ||
      _compact(line).contains('领券购买') ||
      _compact(line).contains('去购买') ||
      _compact(line).contains('免拼购买') ||
      _compact(line).contains('直接拼成') ||
      _compact(line) == '店铺' ||
      _compact(line) == '客服';

  static bool _salesMarker(String compactLine) =>
      compactLine.contains('已售') ||
      compactLine.contains('销量') ||
      compactLine.contains('售出') ||
      compactLine.contains('已拼') ||
      compactLine.contains('热销') ||
      compactLine.contains('热銷');

  static String _compact(String value) => value.replaceAll(RegExp(r'\s+'), '');

  static bool _titleCandidate(String line) {
    final compact = _compact(line);
    if (compact.length < 4 ||
        _salesMarker(compact) ||
        RegExp(r'^\d+[/.:]\d+').hasMatch(compact) ||
        RegExp(r'^\d+/\d+$').hasMatch(compact) ||
        RegExp(r'^\d+$').hasMatch(compact)) {
      return false;
    }
    return RegExp(r'[A-Za-z\u3400-\u9fff]').hasMatch(compact);
  }

  static ShoppingPlatform _platform(List<String> lines) {
    final text = _compact(lines.join(' '));
    if (text.contains('已拼') || text.contains('拼单') || text.contains('免拼购买')) {
      return ShoppingPlatform.pinduoduo;
    }
    if (text.contains('京东') ||
        text.contains('京补') ||
        text.contains('京豆') ||
        text.contains('白条') ||
        text.contains('小金库') ||
        text.contains('PLUS到手价') ||
        text.contains('政府补贴价') ||
        text.contains('明日达') ||
        (text.contains('自营') && text.contains('加入购物车'))) {
      return ShoppingPlatform.jd;
    }
    if (text.contains('淘宝') ||
        text.contains('天猫') ||
        text.contains('民猫') ||
        text.contains('宝贝讲解') ||
        text.contains('领券购买') ||
        text.contains('平台加补后') ||
        text.contains('天降礼金') ||
        text.contains('淘金币')) {
      return ShoppingPlatform.taobao;
    }
    return ShoppingPlatform.unknown;
  }

  static String? _bestTitle(List<String> candidates) {
    if (candidates.isEmpty) return null;
    return candidates.reduce(
      (best, candidate) =>
          _titleScore(candidate) >= _titleScore(best) ? candidate : best,
    );
  }

  static int _titleScore(String value) {
    final hasCjk = RegExp(r'[\u3400-\u9fff]').hasMatch(value);
    final hasLatin = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasQuantity = _quantityPattern.hasMatch(value);
    return value.length + (hasCjk && hasLatin ? 12 : 0) + (hasQuantity ? 8 : 0);
  }

  static List<double> _prices(String line) {
    if (line.contains('/年')) {
      return const [];
    }
    final beforePrice = RegExp(
      r'(?:优惠后|加补后|到手价)\s*[¥￥Yy$*]?\s*(\d+?)(?:[|lI1])?优惠前',
      caseSensitive: false,
    ).firstMatch(line);
    final beforeParsed = double.tryParse(beforePrice?.group(1) ?? '');
    if (beforeParsed != null) return [beforeParsed];

    final concatenated = RegExp(
      r'(?:优惠后|加补后|到手价)\s*[¥￥Yy$*]?\s*(\d+\.\d)(?=\d{2,7}(?:\D|$))',
      caseSensitive: false,
    ).firstMatch(line);
    final concatenatedParsed = double.tryParse(concatenated?.group(1) ?? '');
    if (concatenatedParsed != null) return [concatenatedParsed];

    return _pricePattern
        .allMatches(line)
        .map((match) => double.tryParse(match.group(1) ?? ''))
        .whereType<double>()
        .toList();
  }

  static String? _cleanCartCandidate(String line) {
    if (_promotionOnly(line) || _ignored(line)) return null;
    final cleaned = line
        .replaceFirst(RegExp(r'^(?:狂暑季|超级立减|百亿补贴)\s*'), '')
        .trim();
    if (!_titleCandidate(cleaned)) return null;
    return cleaned;
  }

  static bool _promotionOnly(String line) =>
      _promotion(line) ||
      line.contains('官方立减') ||
      line.contains('礼金') ||
      line.contains('消费券') ||
      line.contains('免息') ||
      line.contains('保险') ||
      line.contains('换购') ||
      line.contains('已免运费') ||
      line.contains('88VIP');

  static bool _shop(String line) =>
      line.contains('旗舰店') || line.contains('专营店') || line.startsWith('天猫');

  static bool _promotion(String line) =>
      line.contains('满减') ||
      line.contains('补贴') ||
      line.contains('退货') ||
      line.contains('价保') ||
      line == '详情';

  static bool _ignored(String line) =>
      line.contains('购物车') ||
      line.contains('结算') ||
      line.contains('合计') ||
      line == '首页' ||
      line == '视频' ||
      line == '消息' ||
      line.contains('我的淘宝');
}
