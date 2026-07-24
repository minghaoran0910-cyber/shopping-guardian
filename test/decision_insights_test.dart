import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/insights/decision_insights.dart';

void main() {
  test('only exposes patterns with enough evidence', () {
    DecisionRecord record(String choice, {String? feedback}) => DecisionRecord(
      itemName: '商品',
      total: 1,
      verdict: choice,
      userChoice: choice,
      summary: '',
      createdAt: DateTime(2026),
      feedback: feedback,
    );
    expect(DecisionInsights.from([record('buy')]).hasEnoughEvidence, isFalse);
    final insights = DecisionInsights.from([
      record('buy', feedback: 'regretted'),
      record('wait'),
      record('skip'),
    ]);
    expect(insights.hasEnoughEvidence, isTrue);
    expect(insights.regretted, 1);
    expect(insights.waited, 1);
    expect(insights.skipped, 1);
  });

  test('does not treat purchase intent as a completed purchase', () {
    final now = DateTime(2026);
    final insights = DecisionInsights.from([
      DecisionRecord(
        itemName: '键盘',
        total: 699,
        verdict: 'buy',
        userChoice: 'buy',
        summary: '',
        createdAt: now,
        events: [DecisionEvent(status: 'intend_to_buy', occurredAt: now)],
      ),
    ]);

    expect(insights.bought, 0);
  });
}
