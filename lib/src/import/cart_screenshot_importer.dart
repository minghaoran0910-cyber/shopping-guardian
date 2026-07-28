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
    r'(?:[¥￥Yy$]|RMB)\s*(\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  static final _barePricePattern = RegExp(r'^\s*(\d{2,7}(?:\.\d{1,2})?)\s*$');
  static final _quantityPattern = RegExp(r'[xX×]\s*(\d+)');

  static List<SharedShoppingItem> parse(List<String> lines) {
    final platform = _platform(lines);
    if (_looksLikeProductDetail(lines)) {
      final detail = _parseProductDetail(lines, platform);
      if (detail != null) return [detail];
    }

    final items = <SharedShoppingItem>[];
    final candidates = <String>[];

    for (final source in lines) {
      final line = source.trim();
      if (line.isEmpty || _ignored(line)) continue;

      final prices = _pricePattern.allMatches(line).toList();
      if (prices.isEmpty) {
        if (!_shop(line) && !_promotion(line)) candidates.add(line);
        continue;
      }

      final title = _bestTitle(candidates);
      candidates.clear();
      if (title == null) continue;
      final price = double.tryParse(prices.first.group(1)!);
      final quantity = _quantityPattern.firstMatch(line)?.group(1);
      items.add(
        SharedShoppingItem(
          platform: platform,
          kind: ShareKind.product,
          url: Uri.parse('local://cart-screenshot/${items.length + 1}'),
          title: title,
          price: price,
          quantity: int.tryParse(quantity ?? '') ?? 1,
        ),
      );
    }
    return items;
  }

  static bool _looksLikeProductDetail(List<String> lines) {
    final text = _compact(lines.join());
    if (text.contains('结算') || text.contains('合计')) return false;
    final hasSales = _salesMarker(text);
    final hasPurchaseAction =
        text.contains('加入购物车') ||
        text.contains('立即购买') ||
        text.contains('马上购买');
    final hasDetailMetadata =
        text.contains('店铺评分') || text.contains('无理由退货') || text.contains('快递');
    return hasSales || (hasPurchaseAction && hasDetailMetadata);
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
      final explicit = _pricePattern.firstMatch(lines[index]);
      if (explicit == null) continue;
      price = double.tryParse(explicit.group(1) ?? '');
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
      _compact(line).contains('加入购物车') ||
      _compact(line).contains('立即购买') ||
      _compact(line) == '店铺' ||
      _compact(line) == '客服';

  static bool _salesMarker(String compactLine) =>
      compactLine.contains('已售') ||
      compactLine.contains('销量') ||
      compactLine.contains('售出');

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
    if (text.contains('京东') || text.contains('JD')) return ShoppingPlatform.jd;
    if (text.contains('淘宝') || text.contains('天猫')) {
      return ShoppingPlatform.taobao;
    }
    return ShoppingPlatform.unknown;
  }

  static String? _bestTitle(List<String> candidates) {
    if (candidates.isEmpty) return null;
    return candidates.reversed.firstWhere(
      (line) => line.length >= 4,
      orElse: () => candidates.last,
    );
  }

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
