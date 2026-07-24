import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/history/decision_history_retriever.dart';
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
        referencedHistory: const ['旧键盘，最后后悔'],
        risk: 'medium',
        confidence: 'high',
        budgetImpact: '占预算 20%',
        alternatives: const ['买二手'],
      ),
    );
    await store.setFeedback('one', 'regretted');
    final record = (await store.readAll()).single;
    expect(record.id, 'one');
    expect(record.feedback, 'regretted');
    expect(record.referencedHistory, ['旧键盘，最后后悔']);
    expect(record.risk, 'medium');
    expect(record.confidence, 'high');
    expect(record.budgetImpact, '占预算 20%');
    expect(record.alternatives, ['买二手']);
  });

  test('reads records created before history references were added', () async {
    SharedPreferences.setMockInitialValues({
      'decision_history_v1': [
        jsonEncode({
          'id': 'legacy',
          'itemName': '旧记录',
          'total': 10,
          'verdict': 'wait',
          'userChoice': 'wait',
          'summary': '旧摘要',
          'createdAt': '2026-01-01T00:00:00.000',
        }),
      ],
    });

    final record = (await const DecisionStore().readAll()).single;
    expect(record.id, 'legacy');
    expect(record.referencedHistory, isEmpty);
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
    final matches = const DecisionHistoryRetriever().findRelevant(
      itemName: '一',
      price: 1,
      records: records,
    );
    expect(matches.map((item) => item.record.id), isNot(contains('one')));
  });

  test(
    'appends status events without overwriting the original choice',
    () async {
      SharedPreferences.setMockInitialValues({});
      const store = DecisionStore();
      final analyzedAt = DateTime(2026, 7, 24, 10);
      final purchasedAt = DateTime(2026, 7, 25, 9);
      await store.add(
        DecisionRecord(
          id: 'one',
          itemName: '键盘',
          total: 699,
          verdict: 'wait',
          userChoice: 'buy',
          summary: '可以考虑',
          createdAt: analyzedAt,
          events: [
            DecisionEvent(status: 'analyzed', occurredAt: analyzedAt),
            DecisionEvent(status: 'intend_to_buy', occurredAt: analyzedAt),
          ],
        ),
      );

      await store.setStatus('one', 'purchased', occurredAt: purchasedAt);
      final record = (await store.readAll()).single;

      expect(record.userChoice, 'buy');
      expect(record.verdict, 'wait');
      expect(record.currentStatus, 'purchased');
      expect(record.events.map((event) => event.status), [
        'analyzed',
        'intend_to_buy',
        'purchased',
      ]);
      expect(record.events.last.occurredAt, purchasedAt);
    },
  );

  test('purchase feedback records purchase and feedback events', () async {
    SharedPreferences.setMockInitialValues({});
    const store = DecisionStore();
    await store.add(
      DecisionRecord(
        id: 'one',
        itemName: '唱片',
        total: 323,
        verdict: 'wait',
        userChoice: 'wait',
        summary: '',
        createdAt: DateTime(2026, 7, 24),
        events: [
          DecisionEvent(status: 'waiting', occurredAt: DateTime(2026, 7, 24)),
        ],
      ),
    );

    await store.setFeedback('one', 'satisfied');
    final record = (await store.readAll()).single;

    expect(record.countsAsPurchased, isTrue);
    expect(record.events.map((event) => event.status), contains('purchased'));
    expect(record.events.last.status, 'feedback_completed');
  });

  test('rejects unsupported decision statuses', () async {
    SharedPreferences.setMockInitialValues({});
    expect(
      () => const DecisionStore().setStatus('one', 'unknown'),
      throwsArgumentError,
    );
  });
}
