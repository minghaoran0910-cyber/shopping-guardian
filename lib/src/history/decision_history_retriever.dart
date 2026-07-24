import 'decision_store.dart';

class DecisionHistoryMatch {
  const DecisionHistoryMatch({required this.record, required this.summary});

  final DecisionRecord record;
  final String summary;
}

class DecisionHistoryRetriever {
  const DecisionHistoryRetriever();

  List<DecisionHistoryMatch> findRelevant({
    required String itemName,
    required double price,
    required List<DecisionRecord> records,
    int limit = 5,
  }) {
    final targetName = _normalize(itemName);
    final targetPairs = _pairs(targetName);
    final scored =
        records
            .map((record) {
              final recordName = _normalize(record.itemName);
              final recordPairs = _pairs(recordName);
              var score = 0.0;

              if (targetName.isNotEmpty &&
                  recordName.isNotEmpty &&
                  (targetName.contains(recordName) ||
                      recordName.contains(targetName))) {
                score += 4;
              }
              if (targetPairs.isNotEmpty && recordPairs.isNotEmpty) {
                final overlap = targetPairs.intersection(recordPairs).length;
                score += 6 * overlap / targetPairs.union(recordPairs).length;
              }

              final priceBase = price.abs() < 1 ? 1.0 : price.abs();
              final priceDifference = (record.total - price).abs() / priceBase;
              if (priceDifference <= 0.2) {
                score += 3;
              } else if (priceDifference <= 0.5) {
                score += 1;
              }
              if (score > 0 && record.feedback != null) score += 0.5;

              return (record: record, score: score);
            })
            .where((candidate) => candidate.score > 0)
            .toList()
          ..sort((a, b) {
            final byScore = b.score.compareTo(a.score);
            return byScore != 0
                ? byScore
                : b.record.createdAt.compareTo(a.record.createdAt);
          });

    return scored
        .take(limit)
        .map(
          (candidate) => DecisionHistoryMatch(
            record: candidate.record,
            summary: _summary(candidate.record),
          ),
        )
        .toList();
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u3400-\u9fff]+'), '');

  static Set<String> _pairs(String value) {
    if (value.isEmpty) return const {};
    if (value.length == 1) return {value};
    return {
      for (var index = 0; index < value.length - 1; index++)
        value.substring(index, index + 2),
    };
  }

  static String _summary(DecisionRecord record) {
    final date = record.createdAt;
    final day =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final feedback = switch (record.feedback) {
      'regretted' => '，购后反馈：后悔',
      'satisfied' => '，购后反馈：满意',
      'rarely_used' => '，购后反馈：很少使用',
      _ => '',
    };
    return '$day，${record.itemName}，¥${record.total.toStringAsFixed(2)}，'
        '用户决定：${record.userChoice}$feedback。${record.summary}';
  }
}
