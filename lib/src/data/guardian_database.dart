import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'guardian_database.g.dart';

@DataClassName('StoredDecision')
class Decisions extends Table {
  TextColumn get id => text()();
  TextColumn get itemName => text()();
  RealColumn get total => real()();
  TextColumn get verdict => text()();
  TextColumn get userChoice => text()();
  TextColumn get summary => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get waitUntil => dateTime().nullable()();
  TextColumn get feedback => text().nullable()();
  TextColumn get usageFrequency => text().nullable()();
  IntColumn get satisfaction => integer().nullable()();
  TextColumn get regretReason => text().nullable()();
  TextColumn get risk => text().nullable()();
  TextColumn get confidence => text().nullable()();
  TextColumn get budgetImpact => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StoredDecisionEvent')
class DecisionEvents extends Table {
  TextColumn get decisionId =>
      text().references(Decisions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get status => text()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {decisionId, position};
}

@DataClassName('StoredDecisionReference')
class DecisionReferences extends Table {
  TextColumn get decisionId =>
      text().references(Decisions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get summary => text()();

  @override
  Set<Column<Object>> get primaryKey => {decisionId, position};
}

@DataClassName('StoredDecisionAlternative')
class DecisionAlternatives extends Table {
  TextColumn get decisionId =>
      text().references(Decisions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {decisionId, position};
}

@DataClassName('StoredConsumptionRule')
class ConsumptionRules extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  RealColumn get minimumAmount => real().nullable()();
  IntColumn get waitDays => integer().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class MigrationQuarantine extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceKey => text()();
  TextColumn get rawValue => text()();
  TextColumn get error => text()();
  DateTimeColumn get quarantinedAt => dateTime()();
}

@DriftDatabase(
  tables: [
    Decisions,
    DecisionEvents,
    DecisionReferences,
    DecisionAlternatives,
    ConsumptionRules,
    AppValues,
    MigrationQuarantine,
  ],
)
class GuardianDatabase extends _$GuardianDatabase {
  GuardianDatabase(super.executor);

  GuardianDatabase.defaults() : super(driftDatabase(name: 'shopping_guardian'));

  GuardianDatabase.memory() : super(NativeDatabase.memory());

  static GuardianDatabase? _instance;

  static GuardianDatabase get instance =>
      _instance ??= GuardianDatabase.defaults();

  static Future<void> useForTesting(GuardianDatabase database) async {
    await _instance?.close();
    _instance = database;
  }

  static Future<void> resetAfterTesting() async {
    await _instance?.close();
    _instance = null;
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(decisions, decisions.usageFrequency);
        await migrator.addColumn(decisions, decisions.satisfaction);
        await migrator.addColumn(decisions, decisions.regretReason);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> clearBusinessData() => transaction(() async {
    await delete(decisionEvents).go();
    await delete(decisionReferences).go();
    await delete(decisionAlternatives).go();
    await delete(decisions).go();
    await delete(consumptionRules).go();
    await delete(appValues).go();
    await delete(migrationQuarantine).go();
  });

  Future<String> availableDecisionId(String preferred) async {
    var candidate = preferred;
    var suffix = 1;
    while (true) {
      final existing = await (select(
        decisions,
      )..where((row) => row.id.equals(candidate))).getSingleOrNull();
      if (existing == null) return candidate;
      candidate = '$preferred-${suffix++}';
    }
  }
}
