import 'package:flutter/services.dart';

import 'share_parser.dart';

class CartScreenshotImporter {
  const CartScreenshotImporter({this.channel = const MethodChannel(_channel)});

  static const _channel = 'shopping_guardian/cart_ocr';
  final MethodChannel channel;

  Future<List<SharedShoppingItem>> pickAndRecognize() async {
    final raw = await channel.invokeListMethod<String>('pickAndRecognize');
    if (raw == null) return const [];
    return CartScreenshotParser.parse(raw);
  }
}

abstract final class CartScreenshotParser {
  static final _pricePattern = RegExp(r'[¥￥]\s*(\d+(?:\.\d{1,2})?)');
  static final _quantityPattern = RegExp(r'[xX×]\s*(\d+)');

  static List<SharedShoppingItem> parse(List<String> lines) {
    final platform = _platform(lines);
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
