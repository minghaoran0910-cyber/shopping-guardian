import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';

void main() {
  test('stores newest decisions first', () async {
    SharedPreferences.setMockInitialValues({});
    const store = DecisionStore();
    await store.add(
      DecisionRecord(
        itemName: '唱片',
        total: 323,
        verdict: 'wait',
        userChoice: 'wait',
        summary: '等一周',
        createdAt: DateTime(2026, 7, 11),
      ),
    );
    await store.add(
      DecisionRecord(
        itemName: '键盘',
        total: 699,
        verdict: 'skip',
        userChoice: 'skip',
        summary: '已有同类',
        createdAt: DateTime(2026, 7, 12),
      ),
    );
    final records = await store.readAll();
    expect(records, hasLength(2));
    expect(records.first.itemName, '键盘');
    expect(records.last.total, 323);
  });
}
