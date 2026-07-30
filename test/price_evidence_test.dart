import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/prices/price_evidence.dart';
import 'package:shopping_guardian/src/prices/price_watch.dart';

void main() {
  PriceSnapshot snapshot({
    required double price,
    required DateTime at,
    double? confidence = 0.9,
    String source = 'justoneapi',
  }) => PriceSnapshot(
    watchId: 'watch-1',
    observedAt: at,
    price: price,
    source: source,
    matchConfidence: confidence,
  );

  test('builds current, previous reference, and a qualified 30-day low', () {
    final now = DateTime(2026, 7, 30, 12);
    final first = snapshot(
      price: 500,
      at: now.subtract(const Duration(days: 2)),
    );
    final low = snapshot(price: 450, at: now.subtract(const Duration(days: 1)));
    final latest = snapshot(
      price: 480,
      at: now.subtract(const Duration(hours: 1)),
    );

    final evidence = PriceEvidence.from([latest, first, low], now: now);

    expect(evidence.current, same(latest));
    expect(evidence.reference, same(low));
    expect(evidence.recentLow, same(low));
    expect(evidence.trustedCount, 3);
  });

  test('does not trust low-confidence or legacy observations', () {
    final now = DateTime(2026, 7, 30, 12);
    final evidence = PriceEvidence.from([
      snapshot(price: 1, at: now, confidence: 0.79),
      snapshot(price: 2, at: now, confidence: null),
    ], now: now);

    expect(evidence.current, isNull);
    expect(evidence.reference, isNull);
    expect(evidence.recentLow, isNull);
    expect(evidence.trustedCount, 0);
  });

  test('reports current price as unknown when the latest quote is stale', () {
    final now = DateTime(2026, 7, 30, 12);
    final stale = snapshot(
      price: 500,
      at: now.subtract(const Duration(hours: 25)),
    );

    final evidence = PriceEvidence.from([stale], now: now);

    expect(evidence.current, isNull);
    expect(evidence.trustedCount, 1);
  });

  test('needs two trusted quotes spanning six hours for a recent low', () {
    final now = DateTime(2026, 7, 30, 12);
    final first = snapshot(
      price: 500,
      at: now.subtract(const Duration(hours: 5)),
    );
    final latest = snapshot(
      price: 450,
      at: now.subtract(const Duration(hours: 1)),
    );

    final evidence = PriceEvidence.from([first, latest], now: now);

    expect(evidence.current, same(latest));
    expect(evidence.reference, same(first));
    expect(evidence.recentLow, isNull);
  });

  test('ignores observations outside the 30-day low window', () {
    final now = DateTime(2026, 7, 30, 12);
    final oldLow = snapshot(
      price: 100,
      at: now.subtract(const Duration(days: 31)),
    );
    final recentFirst = snapshot(
      price: 500,
      at: now.subtract(const Duration(days: 2)),
    );
    final recentLatest = snapshot(
      price: 450,
      at: now.subtract(const Duration(hours: 1)),
    );

    final evidence = PriceEvidence.from([
      oldLow,
      recentFirst,
      recentLatest,
    ], now: now);

    expect(evidence.recentLow, same(recentLatest));
  });

  test('rejects observations with implausible future timestamps', () {
    final now = DateTime(2026, 7, 30, 12);
    final future = snapshot(price: 1, at: now.add(const Duration(minutes: 6)));

    final evidence = PriceEvidence.from([future], now: now);

    expect(evidence.trustedCount, 0);
  });
}
