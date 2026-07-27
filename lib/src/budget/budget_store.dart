import 'package:drift/drift.dart';

import '../data/guardian_database.dart';
import '../data/legacy_data_migrator.dart';
import '../history/decision_store.dart';

class BudgetSnapshot {
  const BudgetSnapshot({required this.limit, required this.spent});

  final double limit;
  final double spent;
  double get left => limit - spent;
}

class BudgetStore {
  const BudgetStore({this.database});

  static const _limitKey = 'monthly_budget_limit';
  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<void> setLimit(double value) async {
    await LegacyDataMigrator(_database).migrate();
    await _database
        .into(_database.appValues)
        .insert(
          AppValuesCompanion.insert(
            key: _limitKey,
            value: value.clamp(0, double.infinity).toString(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<BudgetSnapshot> snapshot() async {
    await LegacyDataMigrator(_database).migrate();
    final value = await (_database.select(
      _database.appValues,
    )..where((row) => row.key.equals(_limitKey))).getSingleOrNull();
    final limit = double.tryParse(value?.value ?? '') ?? 0;
    final now = DateTime.now();
    final records = await DecisionStore(database: _database).readAll();
    final spent = records
        .where(
          (record) =>
              record.countsAsPurchased &&
              record.createdAt.year == now.year &&
              record.createdAt.month == now.month,
        )
        .fold<double>(0, (sum, record) => sum + record.total);
    return BudgetSnapshot(limit: limit, spent: spent);
  }

  Future<void> clear() async {
    await LegacyDataMigrator(_database).migrate();
    await (_database.delete(
      _database.appValues,
    )..where((row) => row.key.equals(_limitKey))).go();
  }
}
