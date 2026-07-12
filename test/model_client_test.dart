import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/analysis/model_client.dart';

void main() {
  test('parses structured purchase advice', () async {
    final client = MockClient(
      (request) async => http.Response(
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"wait\\",\\"summary\\":\\"先等一周\\",\\"reasons\\":[\\"近期有重复购买\\"],\\"missing_information\\":[],\\"wait_days\\":7}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    final advice = await ModelClient(
      baseUrl: 'https://example.com/v1',
      apiKey: 'test',
      model: 'test',
      client: client,
    ).analyze(itemName: '唱片', price: 323);
    expect(advice.verdict, PurchaseVerdict.wait);
    expect(advice.waitDays, 7);
    expect(advice.reasons.single, '近期有重复购买');
  });

  test('repairs malformed JSON once', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      final content = calls == 1
          ? 'not json'
          : '{\\"verdict\\":\\"skip\\",\\"summary\\":\\"不买\\",\\"reasons\\":[],\\"missing_information\\":[]}';
      return http.Response(
        '{"choices":[{"message":{"content":"$content"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final advice = await ModelClient(
      baseUrl: 'https://example.com/v1',
      apiKey: 'test',
      model: 'test',
      client: client,
    ).analyze(itemName: '商品', price: 1);
    expect(calls, 2);
    expect(advice.verdict, PurchaseVerdict.skip);
  });

  test('reports invalid API keys clearly', () async {
    final client = MockClient((_) async => http.Response('{}', 401));
    expect(
      () => ModelClient(
        baseUrl: 'https://example.com/v1',
        apiKey: 'bad',
        model: 'test',
        client: client,
      ).analyze(itemName: '商品', price: 1),
      throwsA(
        isA<ModelClientException>().having(
          (error) => error.message,
          'message',
          contains('API Key'),
        ),
      ),
    );
  });
}
