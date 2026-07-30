import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/analysis/model_client.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/patterns/candidate_fact_recorder.dart';
import 'package:shopping_guardian/src/patterns/pattern_store.dart';
import 'package:shopping_guardian/src/patterns/personal_pattern.dart';

void main() {
  late GuardianDatabase database;
  late PatternStore store;
  late CandidateFactRecorder recorder;

  setUp(() {
    database = GuardianDatabase.memory();
    store = PatternStore(database: database);
    recorder = CandidateFactRecorder(store: store);
  });

  tearDown(() => database.close());

  test(
    'records unchecked facts as candidates and checked facts as confirmed',
    () async {
      await recorder.record(
        facts: const [
          CandidateFact(text: '更偏好轻便耳机', evidence: '购买理由是每天通勤'),
          CandidateFact(text: '容易重复购买键盘', evidence: '已有一把在用键盘'),
        ],
        confirmedIndexes: {0},
        decisionId: 'decision-1',
        at: DateTime(2026, 7, 30),
      );

      final patterns = await store.readAll();
      expect(
        patterns.singleWhere((item) => item.text == '更偏好轻便耳机').status,
        'confirmed',
      );
      final pending = patterns.singleWhere((item) => item.text == '容易重复购买键盘');
      expect(pending.status, 'candidate');
      expect(pending.evidence.single.decisionId, 'decision-1');
      expect(await store.readConfirmedTexts(), ['更偏好轻便耳机']);
    },
  );

  test('never overwrites a fact the user already ignored', () async {
    const text = '总在深夜冲动下单';
    await store.save(
      PersonalPattern(
        id: CandidateFactRecorder.idFor(text),
        text: text,
        status: 'ignored',
        evidence: const [],
      ),
    );

    await recorder.record(
      facts: const [CandidateFact(text: text, evidence: '本次在深夜分析')],
      confirmedIndexes: {0},
      decisionId: 'decision-2',
      at: DateTime(2026, 7, 30),
    );

    expect((await store.readAll()).single.status, 'ignored');
  });

  test('uses a stable normalized id for the same fact', () {
    expect(
      CandidateFactRecorder.idFor(' 偏好轻便耳机 '),
      CandidateFactRecorder.idFor('偏好轻便耳机'),
    );
  });
}
