import 'package:http/http.dart' as http;

import 'justoneapi_client.dart';
import 'share_parser.dart';

class TaobaoProductImporter {
  const TaobaoProductImporter({required this.productDetails, this.client});

  final JustOneApiClient productDetails;
  final http.Client? client;

  Future<SharedShoppingItem> load(Uri shareUrl) async {
    final itemId = await resolveItemId(shareUrl);
    final product = await productDetails.loadTaobaoProduct(itemId);
    return SharedShoppingItem(
      platform: ShoppingPlatform.taobao,
      kind: ShareKind.product,
      url: Uri.parse('https://item.taobao.com/item.htm?id=$itemId'),
      title: product.title,
      price: product.price,
      imageUrl: product.imageUrl,
    );
  }

  Future<String> resolveItemId(Uri shareUrl) async {
    final direct = _findItemId(shareUrl.toString());
    if (direct != null) return direct;

    final requestClient = client ?? http.Client();
    try {
      final response = await requestClient
          .get(
            shareUrl,
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148',
            },
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw TaobaoImportException('HTTP ${response.statusCode}');
      }
      final resolved =
          _findItemId(response.request?.url.toString() ?? '') ??
          _findItemId(response.body);
      if (resolved == null) {
        throw const TaobaoImportException('分享链接里没有找到商品 ID');
      }
      return resolved;
    } finally {
      if (client == null) requestClient.close();
    }
  }

  static String? _findItemId(String value) {
    final normalized = value.replaceAll('&amp;', '&');
    final patterns = [
      RegExp(r'(?:[?&](?:id|itemId)=)(\d{6,})', caseSensitive: false),
      RegExp(r'/i(\d{6,})\.htm', caseSensitive: false),
      RegExp(r'itemId["\\:=]+(\d{6,})', caseSensitive: false),
    ];
    final candidates = <String>[normalized];
    try {
      final decoded = Uri.decodeFull(normalized);
      if (decoded != normalized) candidates.add(decoded);
    } on ArgumentError {
      // Shopping pages often contain CSS percentages or partial percent escapes.
      // The raw HTML is still safe to search for a numeric item id.
    }
    for (final candidate in candidates) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(candidate);
        if (match != null) return match.group(1);
      }
    }
    return null;
  }
}

class TaobaoImportException implements Exception {
  const TaobaoImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
