import 'price_watch.dart';

/// Result of price-manipulation detection.
///
/// "先涨后降" means the seller raised the price before a promotion and then
/// "dropped" it back to roughly the original level, making the discount look
/// bigger than it is.
class PriceManipulation {
  const PriceManipulation({
    required this.detected,
    this.prePromotionPrice,
    this.promotionPrice,
    this.currentPrice,
  });

  /// Whether a likely manipulation pattern was found.
  final bool detected;

  /// The price observed *before* the apparent promotion spike.
  final double? prePromotionPrice;

  /// The inflated price during the apparent promotion window.
  final double? promotionPrice;

  /// The current (post-"drop") price.
  final double? currentPrice;

  static const none = PriceManipulation(detected: false);
}

class PriceEvidence {
  const PriceEvidence({
    this.current,
    this.reference,
    this.recentLow,
    required this.trustedCount,
    this.recentHistory = const [],
    this.manipulation = PriceManipulation.none,
  });

  final PriceSnapshot? current;
  final PriceSnapshot? reference;
  final PriceSnapshot? recentLow;
  final int trustedCount;

  /// Up to 30 recent trusted snapshots for sparkline rendering.
  final List<PriceSnapshot> recentHistory;

  /// Result of "先涨后降" detection.
  final PriceManipulation manipulation;

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

    // Keep at most 30 snapshots for the sparkline.
    final sparkData =
        recent.length > 30 ? recent.sublist(recent.length - 30) : recent;

    final manipulation = _detectManipulation(recent, now);

    return PriceEvidence(
      current: current,
      reference: reference,
      recentLow: recentLow,
      trustedCount: trusted.length,
      recentHistory: sparkData,
      manipulation: manipulation,
    );
  }

  /// Detect "先涨后降" pattern:
  ///
  /// 1. Find a local minimum in the first half of recent data (pre-promotion).
  /// 2. Find a local maximum after that minimum (promotion spike).
  /// 3. Check if the current price is close to (within 5%) the pre-promotion
  ///    minimum, meaning the "discount" just brought it back to normal.
  ///
  /// Requires at least 4 data points spanning at least 3 days.
  static PriceManipulation _detectManipulation(
    List<PriceSnapshot> recent,
    DateTime now,
  ) {
    if (recent.length < 4) return PriceManipulation.none;
    final span = recent.last.observedAt.difference(recent.first.observedAt);
    if (span < const Duration(days: 3)) return PriceManipulation.none;

    final prices = recent.map((s) => s.price).toList();
    final n = prices.length;

    // Find the global minimum in the first 60% of data.
    final firstHalfEnd = (n * 0.6).floor().clamp(1, n - 2);
    var minIdx = 0;
    var minPrice = prices[0];
    for (var i = 1; i < firstHalfEnd; i++) {
      if (prices[i] < minPrice) {
        minPrice = prices[i];
        minIdx = i;
      }
    }

    // Find the global maximum after that minimum.
    var maxIdx = minIdx + 1;
    var maxPrice = prices[minIdx + 1];
    for (var i = minIdx + 1; i < n; i++) {
      if (prices[i] > maxPrice) {
        maxPrice = prices[i];
        maxIdx = i;
      }
    }

    // The spike must be at least 10% above the minimum.
    if (maxPrice <= minPrice * 1.10) return PriceManipulation.none;

    // The current (last) price must be within 5% of the pre-promotion minimum.
    final currentPrice = prices.last;
    if (currentPrice > minPrice * 1.05) return PriceManipulation.none;

    // The maximum must come after the minimum and before the end.
    if (maxIdx <= minIdx || maxIdx >= n - 1) return PriceManipulation.none;

    return PriceManipulation(
      detected: true,
      prePromotionPrice: minPrice,
      promotionPrice: maxPrice,
      currentPrice: currentPrice,
    );
  }
}
