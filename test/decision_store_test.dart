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

  test('keeps cooldown due dates', () async {
    SharedPreferences.setMockInitialValues({});
    const store = DecisionStore();
    final due = DateTime(2026, 7, 19, 12);
    await store.add(
      DecisionRecord(
        itemName: '相机',
        total: 6999,
        verdict: 'wait',
        userChoice: 'wait',
        summary: '冷静一周',
        createdAt: DateTime(2026, 7, 12, 12),
        waitUntil: due,
      ),
    );

    expect((await store.readAll()).single.waitUntil, due);
  });

  test('clears decision history', () async {
    SharedPreferences.setMockInitialValues({});
    const store = DecisionStore();
    await store.add(
      DecisionRecord(
        itemName: '商品',
        total: 1,
        verdict: 'skip',
        userChoice: 'skip',
        summary: '不买',
        createdAt: DateTime(2026),
      ),
    );
    await store.clear();
    expect(await store.readAll(), isEmpty);
  });

  test('updates post-purchase feedback', () async {
    SharedPreferences.setMockInitialValues({});
    const store = DecisionStore();
    await store.add(
      DecisionRecord(
        id: 'one',
        itemName: '商品',
        total: 10,
        verdict: 'buy',
        userChoice: 'buy',
        summary: '可以买',
        createdAt: DateTime(2026),
      ),
    );
    await store.setFeedback('one', 'regretted');
    final record = (await store.readAll()).single;
    expect(record.id, 'one');
    expect(record.feedback, 'regretted');
  });

  test('deletes one decision without affecting others', () async {
    SharedPreferences.setMockInitialValues({});
    const store = DecisionStore();
    await store.add(
      DecisionRecord(
        id: 'one',
        itemName: '一',
        total: 1,
        verdict: 'skip',
        userChoice: 'skip',
        summary: '',
        createdAt: DateTime(2026),
      ),
    );
    await store.add(
      DecisionRecord(
        id: 'two',
        itemName: '二',
        total: 2,
        verdict: 'buy',
        userChoice: 'buy',
        summary: '',
        createdAt: DateTime(2026, 2),
      ),
    );
    await store.delete('one');
    final records = await store.readAll();
    expect(records.single.id, 'two');
  });
}
