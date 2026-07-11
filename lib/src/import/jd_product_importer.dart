import 'package:http/http.dart' as http;

import 'justoneapi_client.dart';
import 'share_parser.dart';

class JdProductImporter {
  const JdProductImporter({required this.productDetails, this.client});

  final JustOneApiClient productDetails;
  final http.Client? client;

  Future<SharedShoppingItem> load(Uri shareUrl) async {
    final itemId = await resolveItemId(shareUrl);
    final product = await productDetails.loadJdProduct(itemId);
    return SharedShoppingItem(
      platform: ShoppingPlatform.jd,
      kind: ShareKind.product,
      url: Uri.parse('https://item.jd.com/$itemId.html'),
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
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ShoppingGuardian/0.1',
            },
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw JdProductImportException('HTTP ${response.statusCode}');
      }
      final resolved =
          _findItemId(response.request?.url.toString() ?? '') ??
          _findItemId(response.body);
      if (resolved == null) {
        throw const JdProductImportException('分享链接里没有找到商品 SKU');
      }
      return resolved;
    } finally {
      if (client == null) requestClient.close();
    }
  }

  static String? _findItemId(String value) {
    final decoded = Uri.decodeFull(value.replaceAll('&amp;', '&'));
    final patterns = [
      RegExp(r'(?:item\.jd\.com/|product/)(\d{6,})', caseSensitive: false),
      RegExp(r'(?:[?&](?:sku|skuId|itemId)=)(\d{6,})', caseSensitive: false),
      RegExp(r'(?:skuId|wareId)["\\:=]+(\d{6,})', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(decoded);
      if (match != null) return match.group(1);
    }
    return null;
  }
}

class JdProductImportException implements Exception {
  const JdProductImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
