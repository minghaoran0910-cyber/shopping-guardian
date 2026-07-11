import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/import/jd_cart_importer.dart';
import 'package:shopping_guardian/src/import/justoneapi_client.dart';

void main() {
  test('extracts JD cart products from the share page', () async {
    final client = MockClient((request) async {
      return http.Response(
        '''
        <ul>
          <li class="bdr-b">
            <div class="short-description"><h4><span>号歌相机手腕带</span></h4><span class="price">￥36.0</span><input class="num_input" value="1"></div>
            <div class="product-thumb"><img src="//img.example/wrist.jpg"></div>
            <span id="63081885510" class="cart-checkbox"></span>
          </li>
          <li class="bdr-b">
            <div class="short-description"><h4><span>号歌富士 X-S10 大拇指手柄</span></h4><span class="price">￥118.0</span><input class="num_input" value="2"></div>
            <div class="product-thumb"><img src="https://img.example/grip.jpg"></div>
            <span id="10029035241515" class="cart-checkbox"></span>
          </li>
        </ul>
      ''',
        200,
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });

    final items = await JdCartImporter(
      client: client,
    ).load(Uri.parse('https://3.cn/example'));

    expect(items, hasLength(2));
    expect(items.first.title, '号歌相机手腕带');
    expect(items.first.price, 36);
    expect(
      items.first.url.toString(),
      'https://item.m.jd.com/product/63081885510.html',
    );
    expect(items.first.imageUrl.toString(), 'https://img.example/wrist.jpg');
    expect(items.last.quantity, 2);
  });

  test('fails clearly when the page has no cart products', () async {
    final client = MockClient(
      (request) async => http.Response('<html></html>', 200),
    );

    expect(
      () =>
          JdCartImporter(client: client).load(Uri.parse('https://3.cn/empty')),
      throwsA(isA<JdCartImportException>()),
    );
  });

  test('keeps page data when product enrichment is offline', () async {
    final pageClient = MockClient(
      (_) async => http.Response(
        '''<li class="bdr-b"><h4><span>页面标题</span></h4><span class="price">￥36</span><span id="63081885510" class="cart-checkbox"></span></li>''',
        200,
        headers: {'content-type': 'text/html; charset=utf-8'},
      ),
    );
    final offlineClient = MockClient(
      (_) async => throw http.ClientException('offline'),
    );

    final items = await JdCartImporter(
      client: pageClient,
      productDetails: JustOneApiClient(token: 'test', client: offlineClient),
    ).load(Uri.parse('https://3.cn/example'));

    expect(items.single.title, '页面标题');
    expect(items.single.price, 36);
  });
}
