import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/import/justoneapi_client.dart';

void main() {
  test('loads normalized JD product details', () async {
    final httpClient = MockClient((request) async {
      expect(request.url.queryParameters['token'], 'test-token');
      expect(request.url.queryParameters['itemId'], '63081885510');
      return http.Response(
        '''{"code":0,"data":{"data1":{"result":{"title":"号歌相机手腕带","currentPrice":"36","lowerPriceyh":"30.60","image":"https://img.example/item.png","shopName":"号歌旗舰店","categoryName":"三脚架/云台/自拍杆"}}}}''',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final product = await JustOneApiClient(
      token: 'test-token',
      client: httpClient,
    ).loadJdProduct('63081885510');

    expect(product.title, '号歌相机手腕带');
    expect(product.price, 36);
    expect(product.lowestPrice, 30.6);
    expect(product.shopName, '号歌旗舰店');
  });

  test('reports API business errors', () async {
    final httpClient = MockClient(
      (_) async => http.Response('{"code":401,"message":"invalid token"}', 200),
    );

    expect(
      () => JustOneApiClient(
        token: 'bad-token',
        client: httpClient,
      ).loadJdProduct('1'),
      throwsA(isA<JustOneApiException>()),
    );
  });

  test('does not create an empty image URL when the API omits it', () async {
    final httpClient = MockClient(
      (_) async => http.Response(
        '{"code":0,"data":{"data1":{"result":{"title":"商品"}}}}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    final product = await JustOneApiClient(
      token: 'test-token',
      client: httpClient,
    ).loadJdProduct('1');

    expect(product.imageUrl, isNull);
  });
}
