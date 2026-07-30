import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/analysis/price_timing_summary.dart';
import 'package:shopping_guardian/src/prices/price_evidence.dart';
import 'package:shopping_guardian/src/prices/price_watch.dart';

void main() {
  PriceSnapshot snapshot(String id, double price, DateTime at) => PriceSnapshot(
    watchId: id,
    observedAt: at,
    price: price,
    source: 'test-provider',
    matchConfidence: 0.9,
  );

  test('marks a trusted current price near the local low', () {
    final now = DateTime(2026, 7, 30, 12);
    final evidence = PriceEvidence.from([
      snapshot('one', 500, now.subtract(const Duration(hours: 8))),
      snapshot('one', 450, now),
    ], now: now);

    final summary = PriceTimingSummary.fromEvidence(evidence);

    expect(summary.status, PriceTimingStatus.nearLocalLow);
    expect(summary.current?.price, 450);
    expect(summary.recentLow?.price, 450);
    expect(summary.toJson()['authority'], contains('不能覆盖需求'));
  });

  test('does not infer timing from one quote or stale evidence', () {
    final now = DateTime(2026, 7, 30, 12);
    final evidence = PriceEvidence.from([
      snapshot('one', 450, now.subtract(const Duration(days: 2))),
    ], now: now);

    final summary = PriceTimingSummary.fromEvidence(evidence);

    expect(summary.status, PriceTimingStatus.insufficient);
    expect(summary.current, isNull);
    expect(summary.toJson()['status'], 'insufficient');
  });
}
