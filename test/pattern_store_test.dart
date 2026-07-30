import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/patterns/pattern_store.dart';
import 'package:shopping_guardian/src/patterns/personal_pattern.dart';

void main() {
  late GuardianDatabase database;

  setUp(() => database = GuardianDatabase.memory());
  tearDown(() => database.close());

  test('保存并覆盖个人规律状态', () async {
    final store = PatternStore(database: database);
    const candidate = PersonalPattern(
      id: '分类:唱片:negative',
      text: '候选规律',
      status: 'candidate',
      evidence: [],
    );
    await store.save(candidate);
    await store.save(candidate.copyWith(status: 'confirmed', text: '已确认'));

    final saved = await store.readAll();
    expect(saved, hasLength(1));
    expect(saved.single.status, 'confirmed');
    expect(saved.single.text, '已确认');
  });

  test('损坏的本地数据安全降级为空列表', () async {
    await database
        .into(database.appValues)
        .insert(
          const AppValuesCompanion(
            key: Value(PatternStore.key),
            value: Value('{'),
          ),
        );
    expect(await PatternStore(database: database).readAll(), isEmpty);
  });

  test('只返回有仍然有效支持依据的已确认规律', () async {
    final store = PatternStore(database: database);
    await store.saveAll([
      const PersonalPattern(
        id: 'confirmed',
        text: '偏好耐用设备',
        status: 'confirmed',
        evidence: [
          PatternEvidence(
            decisionId: 'kept',
            summary: '键盘每天使用 · 5/5',
            supportsPattern: true,
          ),
          PatternEvidence(
            decisionId: 'contrary',
            summary: '另一件设备很少使用 · 2/5',
            supportsPattern: false,
          ),
          PatternEvidence(
            decisionId: 'deleted',
            summary: '已删除的来源',
            supportsPattern: true,
          ),
        ],
      ),
      const PersonalPattern(
        id: 'candidate',
        text: '尚未确认',
        status: 'candidate',
        evidence: [
          PatternEvidence(
            decisionId: 'kept',
            summary: '不应发送',
            supportsPattern: true,
          ),
        ],
      ),
      const PersonalPattern(
        id: 'stale',
        text: '来源已经删除',
        status: 'confirmed',
        evidence: [
          PatternEvidence(
            decisionId: 'deleted',
            summary: '已删除的来源',
            supportsPattern: true,
          ),
        ],
      ),
    ]);

    final references = await store.readConfirmedReferences(
      validDecisionIds: {'kept', 'contrary'},
    );

    expect(references, hasLength(1));
    expect(references.single.id, 'confirmed');
    expect(references.single.supportingEvidence, ['键盘每天使用 · 5/5']);
    expect(references.single.contraryEvidence, ['另一件设备很少使用 · 2/5']);
  });
}
