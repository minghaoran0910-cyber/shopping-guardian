import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/budget/budget_store.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/export/data_importer.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/rules/consumption_rule_store.dart';

Map<String, Object?> decisionJson({
  String id = 'imported-1',
  String itemName = '导入的唱片',
  List<String> alternatives = const [],
}) => {
  'id': id,
  'itemName': itemName,
  'total': 323,
  'verdict': 'wait',
  'userChoice': 'wait',
  'summary': '先等等',
  'createdAt': '2026-07-27T10:00:00.000',
  'waitUntil': null,
  'feedback': null,
  'referencedHistory': ['旧唱片：满意'],
  'risk': 'medium',
  'confidence': 'high',
  'budgetImpact': '本月预算充足',
  'alternatives': alternatives,
  'events': [
    {'status': 'waiting', 'occurredAt': '2026-07-27T10:00:00.000'},
  ],
};

String importJson({
  int version = 2,
  List<Map<String, Object?>>? decisions,
  List<Map<String, Object?>>? rules,
  double budget = 2000,
  bool includeModel = true,
}) => jsonEncode({
  'schema_version': version,
  'monthly_budget': budget,
  if (includeModel)
    'model': {'base_url': 'https://example.com/v1', 'name': 'model'},
  'decisions': decisions ?? [decisionJson()],
  if (version >= 2)
    'rules':
        rules ??
        [
          {
            'id': 'rule-imported',
            'name': '大额等待',
            'description': '超过 500 元等两天',
            'minimumAmount': 500,
            'waitDays': 2,
            'enabled': true,
          },
        ],
});

void main() {
  test('previews v2 data without changing local data', () async {
    SharedPreferences.setMockInitialValues({});
    final importer = DataImporter();

    final preview = await importer.preview(importJson());

    expect(preview.schemaVersion, 2);
    expect(preview.decisions.single.itemName, '导入的唱片');
    expect(preview.rules.single.id, 'rule-imported');
    expect(preview.monthlyBudget, 2000);
    expect(preview.containsModelConfiguration, isTrue);
    expect(await const DecisionStore().readAll(), isEmpty);
    expect(await const ConsumptionRuleStore().readAll(), isEmpty);
    expect((await const BudgetStore().snapshot()).limit, 0);
  });

  test('accepts legacy v1 exports without rules', () async {
    SharedPreferences.setMockInitialValues({});
    await const ConsumptionRuleStore().saveAll([
      const ConsumptionRule(
        id: 'local-rule',
        name: '本机规则',
        description: '旧备份不应删除',
      ),
    ]);
    final importer = DataImporter();

    final preview = await importer.preview(importJson(version: 1));

    expect(preview.decisions, hasLength(1));
    expect(preview.rules, isEmpty);
    expect(preview.containsRules, isFalse);

    await importer.apply(preview, DataImportMode.replace);
    expect(
      (await const ConsumptionRuleStore().readAll()).single.id,
      'local-rule',
    );
  });

  test('rejects unsupported versions and malformed records', () async {
    SharedPreferences.setMockInitialValues({});
    final importer = DataImporter();

    await expectLater(
      importer.preview(importJson(version: 3)),
      throwsA(
        isA<DataImportException>().having(
          (error) => error.message,
          'message',
          contains('不支持'),
        ),
      ),
    );
    await expectLater(
      importer.preview(
        jsonEncode({
          'schema_version': 2,
          'decisions': [
            {...decisionJson(), 'total': '323'},
          ],
          'rules': [],
        }),
      ),
      throwsA(isA<DataImportException>()),
    );
  });

  test('merge skips id conflicts and preserves the existing budget', () async {
    SharedPreferences.setMockInitialValues({});
    await const DecisionStore().add(
      DecisionRecord(
        id: 'imported-1',
        itemName: '本机记录',
        total: 100,
        verdict: 'skip',
        userChoice: 'skip',
        summary: '保留',
        createdAt: DateTime(2026, 7, 1),
      ),
    );
    await const BudgetStore().setLimit(888);
    final importer = DataImporter();
    final preview = await importer.preview(
      importJson(
        decisions: [
          decisionJson(),
          decisionJson(id: 'imported-2', itemName: '新记录'),
        ],
      ),
    );

    expect(preview.decisionConflicts, 1);
    final result = await importer.apply(preview, DataImportMode.merge);
    final records = await const DecisionStore().readAll();

    expect(result.importedDecisions, 1);
    expect(result.importedRules, 1);
    expect(result.skippedConflicts, 1);
    expect(result.budgetImported, isFalse);
    expect(records, hasLength(2));
    expect(
      records.singleWhere((record) => record.id == 'imported-1').itemName,
      '本机记录',
    );
    expect((await const BudgetStore().snapshot()).limit, 888);
  });

  test('replace swaps decisions, rules, and budget in one operation', () async {
    SharedPreferences.setMockInitialValues({});
    await const DecisionStore().add(
      DecisionRecord(
        id: 'local',
        itemName: '本机记录',
        total: 100,
        verdict: 'skip',
        userChoice: 'skip',
        summary: '将被替换',
        createdAt: DateTime(2026, 7, 1),
      ),
    );
    await const ConsumptionRuleStore().saveAll([
      const ConsumptionRule(
        id: 'local-rule',
        name: '本机规则',
        description: '将被替换',
      ),
    ]);
    await const BudgetStore().setLimit(888);
    final importer = DataImporter();
    final preview = await importer.preview(importJson());

    final result = await importer.apply(preview, DataImportMode.replace);

    expect(result.importedDecisions, 1);
    expect((await const DecisionStore().readAll()).single.id, 'imported-1');
    expect(
      (await const ConsumptionRuleStore().readAll()).single.id,
      'rule-imported',
    );
    expect((await const BudgetStore().snapshot()).limit, 2000);
  });

  test('rolls back replacement when any imported child fails', () async {
    SharedPreferences.setMockInitialValues({});
    await const DecisionStore().add(
      DecisionRecord(
        id: 'local',
        itemName: '必须保留',
        total: 100,
        verdict: 'skip',
        userChoice: 'skip',
        summary: '事务失败后仍在',
        createdAt: DateTime(2026, 7, 1),
      ),
    );
    final database = GuardianDatabase.instance;
    await database.customStatement('''
      CREATE TRIGGER fail_imported_alternative
      BEFORE INSERT ON decision_alternatives
      WHEN NEW.description = 'force-failure'
      BEGIN
        SELECT RAISE(ABORT, 'forced import failure');
      END
    ''');
    final importer = DataImporter();
    final preview = await importer.preview(
      importJson(
        decisions: [
          decisionJson(alternatives: ['force-failure']),
        ],
      ),
    );

    await expectLater(
      importer.apply(preview, DataImportMode.replace),
      throwsA(anything),
    );

    final records = await const DecisionStore().readAll();
    expect(records.single.id, 'local');
  });

  test('returns null when file selection is cancelled', () async {
    SharedPreferences.setMockInitialValues({});
    final importer = DataImporter(pickFile: () async => null);

    expect(await importer.pickAndPreview(), isNull);
  });
}
