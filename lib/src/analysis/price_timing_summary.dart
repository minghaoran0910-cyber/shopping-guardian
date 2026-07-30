import '../prices/price_evidence.dart';
import '../prices/price_watch.dart';

enum PriceTimingStatus { nearLocalLow, aboveLocalLow, insufficient }

class PriceTimingSummary {
  const PriceTimingSummary({
    required this.status,
    required this.note,
    this.current,
    this.reference,
    this.recentLow,
    this.trustedCount = 0,
  });

  const PriceTimingSummary.insufficient(this.note)
    : status = PriceTimingStatus.insufficient,
      current = null,
      reference = null,
      recentLow = null,
      trustedCount = 0;

  factory PriceTimingSummary.fromEvidence(PriceEvidence evidence) {
    final current = evidence.current;
    final recentLow = evidence.recentLow;
    if (current == null || recentLow == null) {
      return PriceTimingSummary(
        status: PriceTimingStatus.insufficient,
        note: '没有足够的近期可信记录，无法判断入手时机',
        current: current,
        reference: evidence.reference,
        recentLow: recentLow,
        trustedCount: evidence.trustedCount,
      );
    }
    final nearLow = current.price <= recentLow.price * 1.02;
    return PriceTimingSummary(
      status: nearLow
          ? PriceTimingStatus.nearLocalLow
          : PriceTimingStatus.aboveLocalLow,
      note: nearLow ? '当前价接近本机开始监测后的 30 天低价' : '当前价高于本机开始监测后的 30 天低价',
      current: current,
      reference: evidence.reference,
      recentLow: recentLow,
      trustedCount: evidence.trustedCount,
    );
  }

  final PriceTimingStatus status;
  final String note;
  final PriceSnapshot? current;
  final PriceSnapshot? reference;
  final PriceSnapshot? recentLow;
  final int trustedCount;

  String get auditText {
    final values = <String>[note];
    void add(String label, PriceSnapshot? snapshot) {
      if (snapshot == null) return;
      values.add(
        '$label ¥${snapshot.price.toStringAsFixed(2)}'
        '｜${snapshot.source}'
        '｜${snapshot.observedAt.toIso8601String()}',
      );
    }

    add('当前价', current);
    add('上次可信价', reference);
    add('本机30天低价', recentLow);
    return values.join('\n');
  }

  Map<String, Object?> toJson() => {
    'status': switch (status) {
      PriceTimingStatus.nearLocalLow => 'near_local_30_day_low',
      PriceTimingStatus.aboveLocalLow => 'above_local_30_day_low',
      PriceTimingStatus.insufficient => 'insufficient',
    },
    'scope': 'same_platform_same_item_local_device',
    'note': note,
    'trusted_observation_count': trustedCount,
    'current': _snapshot(current),
    'previous_trusted': _snapshot(reference),
    'local_30_day_low': _snapshot(recentLow),
    'authority': '价格只影响现在买还是等，不能覆盖需求、预算、消费规则或已有物品判断',
  };

  static Map<String, Object?>? _snapshot(PriceSnapshot? value) => value == null
      ? null
      : {
          'price': value.price,
          'source': value.source,
          'observed_at': value.observedAt.toIso8601String(),
          'match_confidence': value.matchConfidence,
        };
}
