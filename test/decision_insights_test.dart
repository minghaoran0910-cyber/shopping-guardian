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
}
