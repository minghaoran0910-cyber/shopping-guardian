import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/budget/budget_store.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/data/legacy_data_migrator.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/rules/consumption_rule_store.dart';

Map<String, Object?> legacyDecision(int index) => {
  'id': 'legacy-$index',
  'itemName': '旧商品 $index',
  'total': index.toDouble(),
  'verdict': 'wait',
  'userChoice': 'wait',
  'summary': '旧摘要',
  'createdAt': DateTime(
    2026,
    1,
    1,
  ).add(Duration(minutes: index)).toIso8601String(),
  'events': [
    {
      'status': 'waiting',
      'occurredAt': DateTime(
        2026,
        1,
        1,
      ).add(Duration(minutes: index)).toIso8601String(),
    },
  ],
};

void main() {
  test(
    'migrates valid legacy data and quarantines one corrupt record',
    () async {
      SharedPreferences.setMockInitialValues({
        'decision_history_v1': [
          jsonEncode(legacyDecision(1)),
          '{"id":"broken"',
        ],
        'consumption_rules_v1': [
          jsonEncode({
            'id': 'rule-1',
            'name': '大额等待',
            'description': '超过 500 元等两天',
            'minimumAmount': 500,
            'waitDays': 2,
            'enabled': true,
          }),
        ],
        'monthly_budget_limit': 3000.0,
      });

      final records = await const DecisionStore().readAll();
      final rules = await const ConsumptionRuleStore().readAll();
      final budget = await const BudgetStore().snapshot();
      final database = GuardianDatabase.instance;
      final quarantined = await database
          .select(database.migrationQuarantine)
          .get();
      final preferences = await SharedPreferences.getInstance();

      expect(records.single.id, 'legacy-1');
      expect(rules.single.id, 'rule-1');
      expect(budget.limit, 3000);
      expect(quarantined, hasLength(1));
      expect(quarantined.single.sourceKey, 'decision_history_v1');
      expect(preferences.containsKey('decision_history_v1'), isFalse);
      expect(preferences.containsKey('consumption_rules_v1'), isFalse);
      expect(preferences.containsKey('monthly_budget_limit'), isFalse);

      expect(await const DecisionStore().readAll(), hasLength(1));
    },
  );

  test(
    'keeps legacy preferences when the migration transaction fails',
    () async {
      SharedPreferences.setMockInitialValues({
        'decision_history_v1': [jsonEncode(legacyDecision(1))],
      });
      final database = GuardianDatabase.instance;
      await database.customStatement('''
      CREATE TRIGGER fail_legacy_marker
      BEFORE INSERT ON app_values
      WHEN NEW.key = 'legacy_shared_preferences_v1_migrated'
      BEGIN
        SELECT RAISE(ABORT, 'forced migration failure');
      END
    ''');

      await expectLater(
        LegacyDataMigrator(database).migrate(),
        throwsA(anything),
      );

      expect(await database.select(database.decisions).get(), isEmpty);
      expect(
        (await SharedPreferences.getInstance()).containsKey(
          'decision_history_v1',
        ),
        isTrue,
      );
    },
  );

  test('migrates 5000 decisions without dropping records', () async {
    SharedPreferences.setMockInitialValues({
      'decision_history_v1': [
        for (var index = 0; index < 5000; index++)
          jsonEncode(legacyDecision(index)),
      ],
    });

    final stopwatch = Stopwatch()..start();
    await LegacyDataMigrator(GuardianDatabase.instance).migrate();
    stopwatch.stop();

    final database = GuardianDatabase.instance;
    final countExpression = database.decisions.id.count();
    final query = database.selectOnly(database.decisions);
    query.addColumns([countExpression]);
    final count = await query
        .map((row) => row.read(countExpression) ?? 0)
        .getSingle();
    expect(count, 5000);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 15)));

    final readStopwatch = Stopwatch()..start();
    final records = await const DecisionStore().readAll();
    readStopwatch.stop();
    expect(records, hasLength(5000));
    expect(readStopwatch.elapsed, lessThan(const Duration(seconds: 15)));
  });

  test('concurrent first reads migrate legacy data only once', () async {
    SharedPreferences.setMockInitialValues({
      'decision_history_v1': [jsonEncode(legacyDecision(4))],
    });

    await Future.wait([
      LegacyDataMigrator(GuardianDatabase.instance).migrate(),
      LegacyDataMigrator(GuardianDatabase.instance).migrate(),
      const DecisionStore().readAll(),
    ]);

    final records = await const DecisionStore().readAll();
    expect(records.single.id, 'legacy-4');
  });

  test(
    'preserves duplicate legacy decision ids with stable suffixes',
    () async {
      final duplicate = legacyDecision(1);
      SharedPreferences.setMockInitialValues({
        'decision_history_v1': [
          jsonEncode(duplicate),
          jsonEncode({...duplicate, 'itemName': '另一件旧商品'}),
        ],
      });

      final records = await const DecisionStore().readAll();

      expect(records, hasLength(2));
      expect(records.map((record) => record.id).toSet(), {
        'legacy-1',
        'legacy-1-1',
      });
      expect(records.map((record) => record.itemName).toSet(), {
        '旧商品 1',
        '另一件旧商品',
      });
    },
  );

  test('quarantines corrupt rules without blocking valid rules', () async {
    SharedPreferences.setMockInitialValues({
      'consumption_rules_v1': [
        '{"id":"broken"',
        jsonEncode({
          'id': 'rule-valid',
          'name': '有效规则',
          'description': '保留这一条',
          'enabled': true,
        }),
      ],
    });

    final rules = await const ConsumptionRuleStore().readAll();
    final quarantined = await GuardianDatabase.instance
        .select(GuardianDatabase.instance.migrationQuarantine)
        .get();

    expect(rules.single.id, 'rule-valid');
    expect(quarantined.single.sourceKey, 'consumption_rules_v1');
  });

  test('keeps migrated data after a file database is reopened', () async {
    final directory = await Directory.systemTemp.createTemp(
      'shopping_guardian_migration_',
    );
    final file = File('${directory.path}/guardian.sqlite');
    SharedPreferences.setMockInitialValues({
      'decision_history_v1': [jsonEncode(legacyDecision(8))],
      'monthly_budget_limit': 2400.0,
    });

    await GuardianDatabase.resetAfterTesting();
    final firstDatabase = GuardianDatabase(NativeDatabase(file));
    await LegacyDataMigrator(firstDatabase).migrate();
    await firstDatabase.close();

    final reopenedDatabase = GuardianDatabase(NativeDatabase(file));
    final records = await DecisionStore(database: reopenedDatabase).readAll();
    final budget = await BudgetStore(database: reopenedDatabase).snapshot();

    expect(records.single.id, 'legacy-8');
    expect(budget.limit, 2400);

    await reopenedDatabase.close();
    await directory.delete(recursive: true);
  });
}
