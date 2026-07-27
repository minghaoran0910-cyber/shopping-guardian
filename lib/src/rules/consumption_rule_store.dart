import 'package:drift/drift.dart';

import '../data/guardian_database.dart';
import '../data/legacy_data_migrator.dart';
import 'consumption_rule.dart';

export 'consumption_rule.dart';

class ConsumptionRuleStore {
  const ConsumptionRuleStore({this.database});

  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<List<ConsumptionRule>> readAll() async {
    await LegacyDataMigrator(_database).migrate();
    final rows = await _database.select(_database.consumptionRules).get();
    return rows
        .map(
          (row) => ConsumptionRule(
            id: row.id,
            name: row.name,
            description: row.description,
            minimumAmount: row.minimumAmount,
            waitDays: row.waitDays,
            enabled: row.enabled,
          ),
        )
        .toList();
  }

  Future<void> saveAll(List<ConsumptionRule> rules) async {
    await LegacyDataMigrator(_database).migrate();
    await _database.transaction(() async {
      await _database.delete(_database.consumptionRules).go();
      for (final rule in rules) {
        await _database
            .into(_database.consumptionRules)
            .insert(
              ConsumptionRulesCompanion.insert(
                id: rule.id,
                name: rule.name,
                description: rule.description,
                minimumAmount: Value(rule.minimumAmount),
                waitDays: Value(rule.waitDays),
                enabled: Value(rule.enabled),
              ),
            );
      }
    });
  }

  Future<List<ConsumptionRule>> matching(double amount) async =>
      (await readAll()).where((rule) => rule.matches(amount)).toList();
}
