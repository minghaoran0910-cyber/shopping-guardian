import 'price_watch.dart';

class PriceEvidence {
  const PriceEvidence({
    this.current,
    this.reference,
    this.recentLow,
    required this.trustedCount,
  });

  final PriceSnapshot? current;
  final PriceSnapshot? reference;
  final PriceSnapshot? recentLow;
  final int trustedCount;

  static PriceEvidence from(
    List<PriceSnapshot> history, {
    required DateTime now,
  }) {
    final latestAllowed = now.add(const Duration(minutes: 5));
    final trusted =
        history
            .where(
              (snapshot) =>
                  snapshot.matchConfidence != null &&
                  snapshot.matchConfidence! >= 0.8 &&
                  snapshot.observedAt.isBefore(latestAllowed),
            )
            .toList()
          ..sort((a, b) => a.observedAt.compareTo(b.observedAt));
    if (trusted.isEmpty) {
      return const PriceEvidence(trustedCount: 0);
    }

    final latest = trusted.last;
    final current =
        now.difference(latest.observedAt) <= const Duration(hours: 24)
        ? latest
        : null;
    final reference = trusted.length >= 2 ? trusted[trusted.length - 2] : null;
    final recent = trusted
        .where(
          (snapshot) => !snapshot.observedAt.isBefore(
            now.subtract(const Duration(days: 30)),
          ),
        )
        .toList();
    final hasUsefulSpan =
        recent.length >= 2 &&
        recent.last.observedAt.difference(recent.first.observedAt) >=
            const Duration(hours: 6);
    PriceSnapshot? recentLow;
    if (hasUsefulSpan) {
      recentLow = recent.reduce(
        (lowest, snapshot) => snapshot.price < lowest.price ? snapshot : lowest,
      );
    }

    return PriceEvidence(
      current: current,
      reference: reference,
      recentLow: recentLow,
      trustedCount: trusted.length,
    );
  }
}
