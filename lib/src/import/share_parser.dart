enum ShoppingPlatform { taobao, jd, unknown }

enum ShareKind { product, collection }

class SharedShoppingItem {
  const SharedShoppingItem({
    required this.platform,
    required this.kind,
    required this.url,
    this.title,
    this.shareCode,
    this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  final ShoppingPlatform platform;
  final ShareKind kind;
  final Uri url;
  final String? title;
  final String? shareCode;
  final double? price;
  final Uri? imageUrl;
  final int quantity;
}

abstract final class ShoppingShareParser {
  static final RegExp _markdownLinkPattern = RegExp(
    r'\[[^\]\r\n]*\]\((https?://[^)\s]+)\)',
  );
  static final RegExp _urlPattern = RegExp(r'https?://[^\s\[\]()<>]+');
  static final RegExp _quotedTitlePattern = RegExp(r'[「『“](.*?)[」』”]');
  static final RegExp _shareCodePattern = RegExp(
    r'(?<![A-Za-z0-9])([A-Z]{2}\d{3,6})(?![A-Za-z0-9])',
  );

  static List<SharedShoppingItem> parse(String input) {
    final normalizedInput = input.replaceAllMapped(
      _markdownLinkPattern,
      (match) => '${match.group(1)!} ',
    );
    final matches = _urlPattern.allMatches(normalizedInput).toList();
    final items = <SharedShoppingItem>[];

    for (var index = 0; index < matches.length; index++) {
      final match = matches[index];
      final rawUrl = _trimUrl(match.group(0)!);
      final uri = Uri.tryParse(rawUrl);
      if (uri == null) continue;

      final previousLineBreak = normalizedInput.lastIndexOf('\n', match.start);
      final contextStart = previousLineBreak < 0 ? 0 : previousLineBreak + 1;
      final contextEnd = index + 1 < matches.length
          ? matches[index + 1].start
          : normalizedInput.length;
      final context = normalizedInput.substring(contextStart, contextEnd);
      final platform = _platformFor(uri);

      if (platform == ShoppingPlatform.unknown) continue;

      final titleMatch = _quotedTitlePattern.firstMatch(context);
      final title = titleMatch?.group(1)?.trim();
      final collection =
          context.contains('购物车') ||
          context.contains('购物清单') ||
          context.toLowerCase().contains('cart');
      final code = _shareCodePattern.firstMatch(context)?.group(1);

      items.add(
        SharedShoppingItem(
          platform: platform,
          kind: collection ? ShareKind.collection : ShareKind.product,
          url: uri,
          title: title?.isEmpty == true ? null : title,
          shareCode: code,
        ),
      );
    }

    return items;
  }

  static ShoppingPlatform _platformFor(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host == 'm.tb.cn' ||
        host == 'e.tb.cn' ||
        host.endsWith('.taobao.com')) {
      return ShoppingPlatform.taobao;
    }
    if (host == '3.cn' || host.endsWith('.jd.com')) {
      return ShoppingPlatform.jd;
    }
    return ShoppingPlatform.unknown;
  }

  static String _trimUrl(String value) =>
      value.replaceFirst(RegExp(r'[，。；、!！?？)）\]】>》]+$'), '');
}
