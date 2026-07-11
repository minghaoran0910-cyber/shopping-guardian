import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'share_parser.dart';
import 'justoneapi_client.dart';

class JdCartImporter {
  const JdCartImporter({this.client, this.productDetails});

  final http.Client? client;
  final JustOneApiClient? productDetails;

  Future<List<SharedShoppingItem>> load(Uri shareUrl) async {
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
        throw JdCartImportException('HTTP ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);
      final items = <SharedShoppingItem>[];

      for (final row in document.querySelectorAll('li.bdr-b')) {
        final title = row.querySelector('h4 span')?.text.trim();
        final priceText = row.querySelector('.price')?.text;
        final quantityText = row
            .querySelector('input.num_input')
            ?.attributes['value'];
        final productId = row.querySelector('.cart-checkbox')?.id;
        final imageSource = row
            .querySelector('.product-thumb img')
            ?.attributes['src'];

        if (title == null ||
            title.isEmpty ||
            productId == null ||
            productId.isEmpty) {
          continue;
        }

        final pageItem = SharedShoppingItem(
          platform: ShoppingPlatform.jd,
          kind: ShareKind.product,
          url: Uri.parse('https://item.m.jd.com/product/$productId.html'),
          title: title,
          price: _parsePrice(priceText),
          quantity: int.tryParse(quantityText ?? '') ?? 1,
          imageUrl: _normalizeImageUrl(imageSource),
        );
        items.add(await _enrich(pageItem, productId));
      }

      if (items.isEmpty) {
        throw const JdCartImportException('页面里没有找到商品');
      }
      return items;
    } finally {
      if (client == null) requestClient.close();
    }
  }

  Future<SharedShoppingItem> _enrich(
    SharedShoppingItem pageItem,
    String productId,
  ) async {
    final details = productDetails;
    if (details == null) return pageItem;
    try {
      final product = await details.loadJdProduct(productId);
      return SharedShoppingItem(
        platform: pageItem.platform,
        kind: pageItem.kind,
        url: pageItem.url,
        title: product.title ?? pageItem.title,
        price: product.price ?? pageItem.price,
        imageUrl: product.imageUrl ?? pageItem.imageUrl,
        quantity: pageItem.quantity,
      );
    } on JustOneApiException {
      return pageItem;
    }
  }

  static double? _parsePrice(String? value) {
    if (value == null) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  static Uri? _normalizeImageUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    return Uri.tryParse(value.startsWith('//') ? 'https:$value' : value);
  }
}

class JdCartImportException implements Exception {
  const JdCartImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
