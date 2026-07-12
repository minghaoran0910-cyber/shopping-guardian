import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/rules/consumption_rule_store.dart';

void main() {
  test('matches only enabled rules above their threshold', () async {
    SharedPreferences.setMockInitialValues({});
    const store = ConsumptionRuleStore();
    await store.saveAll(const [
      ConsumptionRule(
        id: '1',
        name: '大额等待',
        description: '超过 500 元等两天',
        minimumAmount: 500,
        waitDays: 2,
      ),
      ConsumptionRule(
        id: '2',
        name: '已停用',
        description: '不应命中',
        enabled: false,
      ),
    ]);
    expect(await store.matching(400), isEmpty);
    expect((await store.matching(600)).single.name, '大额等待');
  });
}
