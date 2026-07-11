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
}
