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
}
