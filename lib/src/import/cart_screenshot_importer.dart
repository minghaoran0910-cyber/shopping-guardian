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
    if (text.contains('结算') || text.contains('合计')) return false;
    final hasSales = _salesMarker(text);
    final hasPurchaseAction =
        text.contains('加入购物车') ||
        text.contains('立即购买') ||
        text.contains('马上购买') ||
        text.contains('免拼购买') ||
        text.contains('直接拼成');
    final hasDetailMetadata =
        text.contains('店铺评分') || text.contains('无理由退货') || text.contains('快递');
    return hasSales || (hasPurchaseAction && hasDetailMetadata);
  }

  static SharedShoppingItem? _parsePinduoduoDetail(List<String> source) {
    final lines = source.map((line) => line.trim()).toList();
    double? price;
    for (final line in lines) {
      final parsed = _prices(line).firstOrNull;
      if (parsed != null && parsed > 0) {
        price = parsed;
        break;
      }
    }
    if (price == null) return null;

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
    final titleParts = [...titleStarts, ...titleEnds];
    if (titleParts.isEmpty) return null;
    final title = titleParts.join().trim();
    if (title.length < 4) return null;
    return SharedShoppingItem(
      platform: ShoppingPlatform.pinduoduo,
      kind: ShareKind.product,
      url: Uri.parse('local://product-screenshot/1'),
      title: title,
      price: price,
    );
  }

  static SharedShoppingItem? _parseProductDetail(
    List<String> source,
    ShoppingPlatform platform,
  ) {
    final lines = source.map((line) => line.trim()).toList();
    double? price;
    var priceIndex = -1;
    // ML Kit returns lines by text block, not always by strict visual order.
    // On a detail page the sales count can therefore arrive before or after
    // the title. Prefer the first explicit currency amount on the page instead
    // of assuming it must sit immediately before the sales count.
    for (var index = 0; index < lines.length; index++) {
      if (_detailNoise(lines[index])) break;
      final explicit = _prices(lines[index]);
      if (explicit.isEmpty) continue;
      price = explicit.first;
      if (price != null && price > 0) {
        priceIndex = index;
        break;
      }
    }
    // Some Android OCR engines omit the currency sign and return text blocks
    // out of visual order. This branch only runs after the page has already
    // been identified as a product detail, so a standalone amount is safe to
    // consider anywhere before the store/service metadata.
    if (price == null) {
      for (var index = 0; index < lines.length; index++) {
        if (_detailNoise(lines[index])) break;
        final bare = _barePricePattern.firstMatch(lines[index]);
        price = double.tryParse(bare?.group(1) ?? '');
        if (price != null && price >= 10) {
          priceIndex = index;
          break;
        }
      }
    }
    if (price == null || priceIndex < 0) return null;

    final branded = <String>[];
    final supplements = <String>[];
    for (final source in lines) {
      final compact = _compact(source);
      final hasBrandPrefix = RegExp(r'^(?:天猫|民猫|自营|自當)').hasMatch(compact);
      final cleaned = source
          .replaceFirst(RegExp(r'^(?:天猫|民猫|自营|自當)\s*'), '')
          .trim();
      if (_detailNoise(cleaned) ||
          _promotionOnly(cleaned) ||
          _prices(cleaned).isNotEmpty ||
          !_titleCandidate(cleaned)) {
        continue;
      }
      if (hasBrandPrefix) {
        branded.add(cleaned);
      } else if (cleaned.length >= 10) {
        supplements.add(cleaned);
      }
    }
    if (branded.isNotEmpty) {
      final anchor = _bestTitle(branded)!;
      final supplement = _bestTitle(supplements);
      final title = supplement == null ? anchor : '$anchor $supplement';
      return SharedShoppingItem(
        platform: platform,
        kind: ShareKind.product,
        url: Uri.parse('local://product-screenshot/1'),
        title: title,
        price: price,
      );
    }

    final candidates = <({int index, String line})>[];
    for (var index = priceIndex + 1; index < lines.length; index++) {
      final line = lines[index];
      if (_detailNoise(line)) break;
      if (_titleCandidate(line)) candidates.add((index: index, line: line));
    }
    if (candidates.isEmpty) return null;
    final anchor = candidates.reduce(
      (best, candidate) =>
          candidate.line.length > best.line.length ? candidate : best,
    );
    final titleParts = [anchor.line];
    for (final candidate in candidates) {
      if (candidate.index <= anchor.index) continue;
      if (candidate.index > anchor.index + titleParts.length) break;
      titleParts.add(candidate.line);
      if (titleParts.length == 3 || _endsLikeTitle(candidate.line)) break;
    }
    final title = titleParts.join(' ').trim();
    if (title.length < 4) return null;

    return SharedShoppingItem(
      platform: platform,
      kind: ShareKind.product,
      url: Uri.parse('local://product-screenshot/1'),
      title: title,
      price: price,
    );
  }

  static bool _detailNoise(String line) =>
      _compact(line) == '送礼' ||
      _compact(line).contains('店铺评分') ||
      _compact(line).contains('回头客') ||
      _compact(line).contains('发货') ||
      _compact(line).contains('送达') ||
      _compact(line).contains('快递') ||
      _compact(line).contains('无理由退货') ||
      _compact(line).contains('极速退款') ||
      _compact(line).contains('亮点总结') ||
      _compact(line).contains('进一步了解') ||
      _compact(line).contains('可再享') ||
      _compact(line).contains('小金库') ||
      _compact(line).contains('白条') ||
      _compact(line).contains('人浏览') ||
      _compact(line).contains('热卖榜') ||
      _compact(line).contains('加入购物车') ||
      _compact(line).contains('立即购买') ||
      _compact(line) == '店铺' ||
      _compact(line) == '客服';

  static bool _salesMarker(String compactLine) =>
      compactLine.contains('已售') ||
      compactLine.contains('销量') ||
      compactLine.contains('售出') ||
      compactLine.contains('已拼');

  static String _compact(String value) => value.replaceAll(RegExp(r'\s+'), '');

  static bool _endsLikeTitle(String line) =>
      line.endsWith('张') ||
      line.endsWith('套装') ||
      line.endsWith('现货') ||
      line.endsWith('包邮');

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
    final text = lines.join(' ');
    if (text.contains('已拼') || text.contains('拼单') || text.contains('免拼购买')) {
      return ShoppingPlatform.pinduoduo;
    }
    if (text.contains('京东') || text.contains('京补') || text.contains('JD')) {
      return ShoppingPlatform.jd;
    }
    if (text.contains('淘宝') || text.contains('天猫') || text.contains('民猫')) {
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
    if (line.toUpperCase().contains('PLUS') || line.contains('/年')) {
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
