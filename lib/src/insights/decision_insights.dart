import '../history/decision_store.dart';

class DecisionInsights {
  const DecisionInsights({
    required this.total,
    required this.bought,
    required this.waited,
    required this.skipped,
    required this.regretted,
  });
  final int total;
  final int bought;
  final int waited;
  final int skipped;
  final int regretted;
  bool get hasEnoughEvidence => total >= 3;

  factory DecisionInsights.from(List<DecisionRecord> records) =>
      DecisionInsights(
        total: records.length,
        bought: records.where((r) => r.countsAsPurchased).length,
        waited: records
            .where(
              (r) =>
                  r.effectiveEvents.any((event) => event.status == 'waiting'),
            )
            .length,
        skipped: records
            .where(
              (r) =>
                  r.effectiveEvents.any((event) => event.status == 'skipped'),
            )
            .length,
        regretted: records.where((r) => r.feedback == 'regretted').length,
      );
}
