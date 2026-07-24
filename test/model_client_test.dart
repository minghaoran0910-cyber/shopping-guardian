import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopping_guardian/src/analysis/model_client.dart';

void main() {
  test('sends only the selected history summaries', () async {
    late Map<String, dynamic> requestBody;
    final client = MockClient((request) async {
      requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"wait\\",\\"summary\\":\\"参考过去先等等\\",\\"reasons\\":[],\\"missing_information\\":[]}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    await ModelClient(
      baseUrl: 'https://example.com/v1',
      apiKey: 'secret-key',
      model: 'test',
      client: client,
    ).analyze(
      itemName: '键盘',
      price: 699,
      relatedHistory: const ['过去买过同类键盘，后来很少使用'],
    );

    final messages = requestBody['messages'] as List;
    final input =
        jsonDecode((messages.last as Map<String, dynamic>)['content'] as String)
            as Map<String, dynamic>;
    expect(input['related_history'], ['过去买过同类键盘，后来很少使用']);
    expect(jsonEncode(requestBody), isNot(contains('secret-key')));
  });

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
