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
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"wait\\",\\"risk\\":\\"medium\\",\\"confidence\\":\\"high\\",\\"summary\\":\\"参考过去先等等\\",\\"reasons\\":[],\\"budget_impact\\":\\"占剩余预算一半\\",\\"alternatives\\":[],\\"missing_information\\":[]}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    await ModelClient(
      endpoint: 'https://example.com/v1/chat/completions',
      apiKey: 'secret-key',
      model: 'test',
      client: client,
    ).analyze(
      itemName: '键盘',
      price: 699,
      relatedHistory: const ['过去买过同类键盘，后来很少使用'],
      confirmedPatterns: const ['我确认：买键盘前先检查已有设备'],
      ownedItems: const ['旧键盘 ×1（仍在使用；办公）'],
    );

    final messages = requestBody['messages'] as List;
    final input =
        jsonDecode((messages.last as Map<String, dynamic>)['content'] as String)
            as Map<String, dynamic>;
    expect(input['related_history'], ['过去买过同类键盘，后来很少使用']);
    expect(input['confirmed_patterns'], ['我确认：买键盘前先检查已有设备']);
    expect(input['owned_items_same_category'], ['旧键盘 ×1（仍在使用；办公）']);
    expect(jsonEncode(requestBody), isNot(contains('secret-key')));
  });

  test('parses structured purchase advice', () async {
    final client = MockClient(
      (request) async => http.Response(
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"wait\\",\\"risk\\":\\"medium\\",\\"confidence\\":\\"high\\",\\"summary\\":\\"先等一周\\",\\"reasons\\":[\\"近期有重复购买\\"],\\"budget_impact\\":\\"占预算 20%\\",\\"alternatives\\":[\\"先租用\\"],\\"missing_information\\":[],\\"wait_days\\":7,\\"candidate_facts\\":[{\\"text\\":\\"容易重复购买唱片\\",\\"evidence\\":\\"近期有重复购买记录\\"}]}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    final advice = await ModelClient(
      endpoint: 'https://example.com/v1/chat/completions',
      apiKey: 'test',
      model: 'test',
      client: client,
    ).analyze(itemName: '唱片', price: 323);
    expect(advice.verdict, PurchaseVerdict.wait);
    expect(advice.waitDays, 7);
    expect(advice.reasons.single, '近期有重复购买');
    expect(advice.risk, AdviceLevel.medium);
    expect(advice.confidence, AdviceLevel.high);
    expect(advice.budgetImpact, '占预算 20%');
    expect(advice.alternatives, ['先租用']);
    expect(advice.candidateFacts.single.text, '容易重复购买唱片');
    expect(advice.candidateFacts.single.evidence, '近期有重复购买记录');
  });

  test(
    'filters unsupported, duplicate, and excessive candidate facts',
    () async {
      final tooLong = List.filled(121, '很').join();
      final content = jsonEncode({
        'verdict': 'wait',
        'risk': 'medium',
        'confidence': 'medium',
        'summary': '等等',
        'reasons': [],
        'budget_impact': '未知',
        'alternatives': [],
        'missing_information': [],
        'candidate_facts': [
          {'text': '偏好轻便设备', 'evidence': '购买理由提到通勤'},
          {'text': '偏好轻便设备', 'evidence': '重复'},
          {'text': '没有依据'},
          {'text': tooLong, 'evidence': '太长'},
          {'text': '第二条有效事实', 'evidence': '相关历史直接支持'},
        ],
      });
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': content},
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      final advice = await ModelClient(
        endpoint: 'https://example.com/v1/chat/completions',
        apiKey: '',
        model: 'test',
        client: client,
      ).analyze(itemName: '耳机', price: 399);
      expect(advice.candidateFacts.map((fact) => fact.text), [
        '偏好轻便设备',
        '第二条有效事实',
      ]);
    },
  );

  test('keeps alternative verdict distinct from insufficient data', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"alternative\\",\\"risk\\":\\"low\\",\\"confidence\\":\\"medium\\",\\"summary\\":\\"先找替代\\",\\"reasons\\":[],\\"budget_impact\\":\\"可减少支出\\",\\"alternatives\\":[\\"买二手\\"],\\"missing_information\\":[]}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    final advice = await ModelClient(
      endpoint: 'https://example.com/v1/chat/completions',
      apiKey: 'test',
      model: 'test',
      client: client,
    ).analyze(itemName: '键盘', price: 699);

    expect(advice.verdict, PurchaseVerdict.alternative);
    expect(advice.alternatives, ['买二手']);
  });

  test('repairs malformed JSON once', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      final content = calls == 1
          ? 'not json'
          : '{\\"verdict\\":\\"skip\\",\\"risk\\":\\"high\\",\\"confidence\\":\\"high\\",\\"summary\\":\\"不买\\",\\"reasons\\":[],\\"budget_impact\\":\\"超出预算\\",\\"alternatives\\":[],\\"missing_information\\":[]}';
      return http.Response(
        '{"choices":[{"message":{"content":"$content"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final advice = await ModelClient(
      endpoint: 'https://example.com/v1/chat/completions',
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
        endpoint: 'https://example.com/v1/chat/completions',
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

  test('uses the exact endpoint and can omit JSON mode and auth', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"skip\\",\\"risk\\":\\"low\\",\\"confidence\\":\\"high\\",\\"summary\\":\\"不买\\",\\"reasons\\":[],\\"budget_impact\\":\\"无\\",\\"alternatives\\":[],\\"missing_information\\":[]}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    await ModelClient(
      endpoint: 'http://localhost:11434/v1/chat/completions?tenant=local',
      apiKey: '',
      model: 'local-model',
      useStructuredOutput: false,
      client: client,
    ).analyze(itemName: '商品', price: 1);

    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(
      captured.url.toString(),
      'http://localhost:11434/v1/chat/completions?tenant=local',
    );
    expect(captured.headers, isNot(contains('authorization')));
    expect(body, isNot(contains('response_format')));
  });

  test('retries 429 and 5xx with bounded delays before succeeding', () async {
    var calls = 0;
    final delays = <Duration>[];
    final client = MockClient((_) async {
      calls++;
      if (calls == 1) {
        return http.Response('{}', 429, headers: {'retry-after': '1'});
      }
      if (calls == 2) return http.Response('{}', 503);
      return http.Response(
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"wait\\",\\"risk\\":\\"medium\\",\\"confidence\\":\\"high\\",\\"summary\\":\\"等等\\",\\"reasons\\":[],\\"budget_impact\\":\\"低\\",\\"alternatives\\":[],\\"missing_information\\":[]}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final advice = await ModelClient(
      endpoint: 'https://example.com/chat/completions',
      apiKey: 'key',
      model: 'model',
      client: client,
      retryDelay: (duration) async => delays.add(duration),
    ).analyze(itemName: '商品', price: 1);

    expect(advice.verdict, PurchaseVerdict.wait);
    expect(calls, 3);
    expect(delays, [const Duration(seconds: 1), const Duration(seconds: 1)]);
  });

  test('treats a non-positive model wait period as unspecified', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"choices":[{"message":{"content":"{\\"verdict\\":\\"skip\\",'
        '\\"risk\\":\\"low\\",\\"confidence\\":\\"high\\",'
        '\\"summary\\":\\"无需等待\\",\\"reasons\\":[],'
        '\\"budget_impact\\":\\"低\\",\\"alternatives\\":[],'
        '\\"missing_information\\":[],\\"wait_days\\":0}"}}]}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    final advice = await ModelClient(
      endpoint: 'https://example.com/chat/completions',
      apiKey: 'key',
      model: 'model',
      client: client,
    ).analyze(itemName: '商品', price: 1);

    expect(advice.waitDays, isNull);
  });

  test('stops after the configured retry limit', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return http.Response('{}', 500);
    });

    await expectLater(
      ModelClient(
        endpoint: 'https://example.com/chat/completions',
        apiKey: 'key',
        model: 'model',
        client: client,
        retryDelay: (_) async {},
      ).analyze(itemName: '商品', price: 1),
      throwsA(
        isA<ModelClientException>().having(
          (error) => error.message,
          'message',
          contains('HTTP 500'),
        ),
      ),
    );
    expect(calls, 3);
  });

  test('does not retry non-transient client errors', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return http.Response('{}', 404);
    });

    await expectLater(
      ModelClient(
        endpoint: 'https://example.com/chat/completions',
        apiKey: 'key',
        model: 'model',
        client: client,
        retryDelay: (_) async {},
      ).analyze(itemName: '商品', price: 1),
      throwsA(isA<ModelClientException>()),
    );
    expect(calls, 1);
  });
}
