import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/import/jd_product_importer.dart';
import 'package:shopping_guardian/src/import/justoneapi_client.dart';

void main() {
  test('resolves a JD short link and loads product details', () async {
    final shareClient = MockClient(
      (_) async => http.Response(
        '<a href="https://item.jd.com/10029035241515.html">item</a>',
        200,
      ),
    );
    final apiClient = MockClient(
      (_) async => http.Response(
        '{"code":0,"data":{"data1":{"result":{"title":"富士相机拇指手柄","currentPrice":"118"}}}}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    final item = await JdProductImporter(
      client: shareClient,
      productDetails: JustOneApiClient(token: 'test', client: apiClient),
    ).load(Uri.parse('https://3.cn/example'));

    expect(item.title, '富士相机拇指手柄');
    expect(item.price, 118);
    expect(item.url.toString(), 'https://item.jd.com/10029035241515.html');
  });

  test('extracts a SKU directly from a JD item URL', () async {
    final importer = JdProductImporter(
      productDetails: JustOneApiClient(token: 'test'),
    );

    expect(
      await importer.resolveItemId(
        Uri.parse('https://item.jd.com/10029035241515.html'),
      ),
      '10029035241515',
    );
  });
}
