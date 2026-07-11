import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/import/justoneapi_client.dart';
import 'package:shopping_guardian/src/import/taobao_product_importer.dart';

void main() {
  test('extracts a Taobao item id from a resolved share page', () async {
    final shareClient = MockClient(
      (_) async => http.Response(
        '<script>location.href="https://item.taobao.com/item.htm?id=812345678901"</script>',
        200,
      ),
    );
    final apiClient = MockClient(
      (_) async => http.Response(
        '{"code":0,"data":{"data1":{"result":{"title":"测试商品","currentPrice":"99","image":"https://img.example/tb.png"}}}}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    final item = await TaobaoProductImporter(
      client: shareClient,
      productDetails: JustOneApiClient(token: 'test', client: apiClient),
    ).load(Uri.parse('https://m.tb.cn/example'));

    expect(item.title, '测试商品');
    expect(item.price, 99);
    expect(item.url.queryParameters['id'], '812345678901');
  });

  test('extracts an id directly from a Taobao item URL', () async {
    final importer = TaobaoProductImporter(
      productDetails: JustOneApiClient(token: 'test'),
    );

    expect(
      await importer.resolveItemId(
        Uri.parse('https://item.taobao.com/item.htm?id=812345678901'),
      ),
      '812345678901',
    );
  });
}
