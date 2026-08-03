import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';
import 'package:shopping_guardian/src/prices/external_price_history_provider.dart';
import 'package:shopping_guardian/src/prices/price_watch.dart';

void main() {
  final watch = PriceWatch(
    id: 'w',
    decisionId: 'd',
    itemName: '耳机',
    platform: ShoppingPlatform.jd,
    itemId: '123',
    productUrl: Uri.parse('https://item.jd.com/123.html'),
    targetPrice: 500,
    createdAt: DateTime(2026),
  );

  test('imports only identity-verified, valid external history', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters, {'platform': 'jd', 'item_id': '123'});
      expect(request.headers['authorization'], 'Bearer secret');
      return http.Response('''{"platform":"jd","item_id":"123","history":[
        {"price":499,"observed_at":"2026-07-01T10:00:00Z","match_confidence":0.95},
        {"price":0,"observed_at":"2026-07-02T10:00:00Z","match_confidence":0.9}
      ]}''', 200);
    });
    final history = await ExternalPriceHistoryProvider(
      endpoint: Uri.parse('https://history.example/v1/prices'),
      token: 'secret',
      client: client,
    ).fetch(watch);
    expect(history, hasLength(1));
    expect(history.single.source, 'external_history');
    expect(history.single.price, 499);
  });

  test('rejects history for a different product identity', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"platform":"jd","item_id":"other","history":[]}',
        200,
      ),
    );
    expect(
      () => ExternalPriceHistoryProvider(
        endpoint: Uri.parse('https://history.example'),
        client: client,
      ).fetch(watch),
      throwsA(isA<ExternalPriceHistoryException>()),
    );
  });
}
