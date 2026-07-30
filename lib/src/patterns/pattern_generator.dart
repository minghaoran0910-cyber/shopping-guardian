import '../history/decision_record.dart';
import 'personal_pattern.dart';

class PatternGenerator {
  const PatternGenerator();

  List<PersonalPattern> merge(
    List<PersonalPattern> generated,
    List<PersonalPattern> stored,
  ) {
    final saved = {for (final pattern in stored) pattern.id: pattern};
    final visible = <PersonalPattern>[];
    for (final candidate in generated) {
      final existing = saved.remove(candidate.id);
      if (existing?.status == 'ignored') continue;
      if (existing?.status == 'confirmed') {
        visible.add(existing!);
      } else {
        visible.add(candidate);
      }
    }
    visible.addAll(
      saved.values.where((pattern) => pattern.status == 'confirmed'),
    );
    visible.sort((a, b) {
      if (a.status == b.status) return a.id.compareTo(b.id);
      return a.status == 'candidate' ? -1 : 1;
    });
    return visible;
  }

  List<PersonalPattern> generate(List<DecisionRecord> records) {
    final groups = <String, List<DecisionRecord>>{};
    for (final record in records) {
      if (!record.countsAsPurchased || !_hasPreferenceEvidence(record)) {
        continue;
      }
      if (record.category?.trim().isNotEmpty == true) {
        groups
            .putIfAbsent('分类:${record.category!.trim()}', () => [])
            .add(record);
      }
      for (final tag in record.tags) {
        groups.putIfAbsent('标签:${tag.trim()}', () => []).add(record);
      }
    }

    final patterns = <PersonalPattern>[];
    for (final entry in groups.entries) {
      final unique = {
        for (final record in entry.value) record.id: record,
      }.values.toList();
      if (unique.length < 3) continue;
      final negative = unique.where(_isNegative).length;
      final positive = unique.where(_isPositive).length;
      final kind = negative >= 2 && negative * 2 >= unique.length
          ? 'negative'
          : positive >= 2 && positive * 2 >= unique.length
          ? 'positive'
          : null;
      if (kind == null) continue;
      final label = entry.key.substring(3);
      final text = kind == 'negative'
          ? '你在“$label”相关购买中多次低频使用或后悔，购买前应先确认具体使用场景。'
          : '你对“$label”相关购买的使用和满意度较高，可把它作为更匹配你的类别。';
      patterns.add(
        PersonalPattern(
          id: '${entry.key}:$kind',
          text: text,
          status: 'candidate',
          evidence: unique
              .map(
                (record) => PatternEvidence(
                  decisionId: record.id,
                  summary:
                      '${record.itemName} · ${record.currentStatus}'
                      '${record.satisfaction == null ? '' : ' · ${record.satisfaction}/5'}',
                  supportsPattern: kind == 'negative'
                      ? _isNegative(record)
                      : _isPositive(record),
                ),
              )
              .toList(),
        ),
      );
    }
    return patterns;
  }

  bool _isNegative(DecisionRecord record) =>
      record.feedback == 'regretted' ||
      (record.satisfaction != null && record.satisfaction! <= 2) ||
      record.usageFrequency == 'rarely' ||
      record.usageFrequency == 'not_used';

  bool _isPositive(DecisionRecord record) =>
      record.feedback == 'satisfied' &&
      (record.satisfaction == null || record.satisfaction! >= 4) &&
      (record.usageFrequency == 'weekly' || record.usageFrequency == 'daily');

  bool _hasPreferenceEvidence(DecisionRecord record) =>
      record.usageFrequency != null ||
      record.satisfaction != null ||
      record.feedback == 'regretted';
}
