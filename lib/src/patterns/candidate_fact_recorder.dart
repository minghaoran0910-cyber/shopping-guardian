import '../analysis/model_client.dart';
import 'pattern_store.dart';
import 'personal_pattern.dart';

class CandidateFactRecorder {
  const CandidateFactRecorder({this.store = const PatternStore()});

  final PatternStore store;

  Future<void> record({
    required List<CandidateFact> facts,
    required Set<int> confirmedIndexes,
    required String decisionId,
    required DateTime at,
  }) async {
    final stored = {
      for (final pattern in await store.readAll()) pattern.id: pattern,
    };
    final updates = <PersonalPattern>[];
    for (final (index, fact) in facts.indexed) {
      final patternId = idFor(fact.text);
      final existing = stored[patternId];
      if (existing?.status == 'confirmed' || existing?.status == 'ignored') {
        continue;
      }
      final evidence = [
        ...?existing?.evidence,
        PatternEvidence(
          decisionId: decisionId,
          summary: fact.evidence,
          supportsPattern: true,
        ),
      ];
      final pattern = PersonalPattern(
        id: patternId,
        text: fact.text,
        status: confirmedIndexes.contains(index) ? 'confirmed' : 'candidate',
        evidence: evidence,
        updatedAt: at,
      );
      updates.add(pattern);
      stored[patternId] = pattern;
    }
    await store.saveAll(updates);
  }

  static String idFor(String text) {
    var hash = 0x811c9dc5;
    for (final unit in text.trim().toLowerCase().codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'model_fact_${hash.toRadixString(16).padLeft(8, '0')}';
  }
}
