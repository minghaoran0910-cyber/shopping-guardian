import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/budget/budget_store.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';

void main() {
  test('calculates this month purchased total', () async {
    SharedPreferences.setMockInitialValues({});
    const budgets = BudgetStore();
    await budgets.setLimit(2000);
    final now = DateTime.now();
    await const DecisionStore().add(
      DecisionRecord(
        itemName: '唱片',
        total: 323,
        verdict: 'buy',
        userChoice: 'buy',
        summary: '买',
        createdAt: now,
      ),
    );
    await const DecisionStore().add(
      DecisionRecord(
        itemName: '键盘',
        total: 699,
        verdict: 'skip',
        userChoice: 'skip',
        summary: '不买',
        createdAt: now,
      ),
    );

    final snapshot = await budgets.snapshot();
    expect(snapshot.limit, 2000);
    expect(snapshot.spent, 323);
    expect(snapshot.left, 1677);
  });

  test('clears monthly budget', () async {
    SharedPreferences.setMockInitialValues({});
    const store = BudgetStore();
    await store.setLimit(1000);
    await store.clear();
    expect((await store.snapshot()).limit, 0);
  });
}
