import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/patterns/confirmed_pattern_reference.dart';
import 'package:shopping_guardian/src/profile/consumer_profile.dart';
import 'package:shopping_guardian/src/profile/consumer_profile_generator.dart';
import 'package:shopping_guardian/src/profile/consumer_profile_store.dart';

void main() {
  test('证据不足时不强行生成消费人格', () {
    final profile = const ConsumerProfileGenerator().fromEvidence([
      const ConfirmedPatternReference(
        id: 'one',
        text: '偏好耐用设备',
        supportingEvidence: ['确认记录'],
        contraryEvidence: [],
      ),
      const ConfirmedPatternReference(
        id: 'two',
        text: '会等待价格',
        supportingEvidence: ['确认记录'],
        contraryEvidence: [],
      ),
    ]);
    expect(profile, isNull);
  });

  test('三条确认偏好可生成可编辑的娱乐性结果', () {
    final profile = const ConsumerProfileGenerator().fromEvidence([
      const ConfirmedPatternReference(
        id: '分类:数码:positive',
        text: '常用数码产品满意度较高',
        supportingEvidence: ['确认记录'],
        contraryEvidence: [],
      ),
      const ConfirmedPatternReference(
        id: '标签:耐用:positive',
        text: '更重视耐用',
        supportingEvidence: ['确认记录'],
        contraryEvidence: ['也买过一件短期使用的产品'],
      ),
      const ConfirmedPatternReference(
        id: '标签:办公:negative',
        text: '办公配件偶尔重复购买',
        supportingEvidence: ['确认记录'],
        contraryEvidence: [],
      ),
    ], now: DateTime(2026, 7, 30));

    expect(profile, isNotNull);
    expect(profile!.title, '长期使用派');
    expect(profile.traits, hasLength(3));
    expect(profile.reminder, contains('相反记录'));
    expect(profile.source, 'evidence');
    expect(profile.isValid, isTrue);
  });

  test('本地趣味问答结果不需要模型或购物明细', () {
    final profile = const ConsumerProfileGenerator().fromQuiz([
      0,
      0,
      1,
      0,
    ], now: DateTime(2026, 7, 30));

    expect(profile.title, '冷静规划派');
    expect(profile.traits, hasLength(3));
    expect(profile.source, 'quiz');
    expect(profile.shareCardPayload.keys, {
      'title',
      'traits',
      'reminder',
      'disclaimer',
      'app_name',
      'project_url',
    });
    final payload = profile.shareCardPayload.toString();
    expect(payload, isNot(contains('price')));
    expect(payload, isNot(contains('order')));
    expect(payload, isNot(contains('api')));
    expect(payload, isNot(contains('model')));
    expect(payload, isNot(contains('商品')));
    expect(payload, contains('不是心理测评'));
  });

  test('消费人格保存在本地并对损坏数据安全降级', () async {
    final database = GuardianDatabase.memory();
    addTearDown(database.close);
    final store = ConsumerProfileStore(database: database);
    final profile = const ConsumerProfileGenerator().fromQuiz([0, 1, 0, 1]);

    await store.save(profile);
    expect((await store.read())?.title, profile.title);

    await database
        .into(database.appValues)
        .insertOnConflictUpdate(
          const AppValuesCompanion(
            key: Value(ConsumerProfileStore.key),
            value: Value('{'),
          ),
        );
    expect(await store.read(), isNull);
  });

  test('拒绝字段过长或缺少三项特点的分享结果', () {
    expect(
      ConsumerProfile(
        title: '过长的消费人格名称超过二十四个字符所以不能被保存和分享',
        traits: const ['一', '二'],
        reminder: '提醒',
        source: 'quiz',
        updatedAt: DateTime(2026),
      ).isValid,
      isFalse,
    );
  });
}
