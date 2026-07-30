import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';

void main() {
  test('migrates a v1 database through price evidence v8', () async {
    await GuardianDatabase.resetAfterTesting();
    final database = GuardianDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
            CREATE TABLE decisions (
              id TEXT NOT NULL PRIMARY KEY,
              item_name TEXT NOT NULL,
              total REAL NOT NULL,
              verdict TEXT NOT NULL,
              user_choice TEXT NOT NULL,
              summary TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              wait_until INTEGER,
              feedback TEXT,
              risk TEXT,
              confidence TEXT,
              budget_impact TEXT
            )
          ''');
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(database.close);

    final columns = await database
        .customSelect("PRAGMA table_info('decisions')")
        .get();
    final names = columns.map((row) => row.read<String>('name')).toSet();

    expect(database.schemaVersion, 8);
    expect(
      names,
      containsAll([
        'usage_frequency',
        'satisfaction',
        'regret_reason',
        'category',
        'price_timing_evidence',
      ]),
    );
    final priceColumns = await database
        .customSelect("PRAGMA table_info('price_observations')")
        .get();
    expect(
      priceColumns.map((row) => row.read<String>('name')),
      contains('match_confidence'),
    );
    final tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    expect(
      tables.map((row) => row.read<String>('name')),
      containsAll([
        'decision_tags',
        'decision_pattern_references',
        'price_watches',
        'price_observations',
        'owned_items',
        'decision_owned_references',
      ]),
    );
  });

  test('adds price confidence to an existing v6 observation table', () async {
    await GuardianDatabase.resetAfterTesting();
    final database = GuardianDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
            CREATE TABLE decisions (
              id TEXT NOT NULL PRIMARY KEY,
              item_name TEXT NOT NULL,
              total REAL NOT NULL,
              verdict TEXT NOT NULL,
              user_choice TEXT NOT NULL,
              summary TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              wait_until INTEGER,
              feedback TEXT,
              usage_frequency TEXT,
              satisfaction INTEGER,
              regret_reason TEXT,
              category TEXT,
              risk TEXT,
              confidence TEXT,
              budget_impact TEXT
            )
          ''');
          raw.execute('''
            CREATE TABLE price_observations (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              watch_id TEXT NOT NULL,
              observed_at INTEGER NOT NULL,
              price REAL NOT NULL,
              source TEXT NOT NULL
            )
          ''');
          raw.execute('PRAGMA user_version = 6');
        },
      ),
    );
    addTearDown(database.close);

    final columns = await database
        .customSelect("PRAGMA table_info('price_observations')")
        .get();

    expect(
      columns.map((row) => row.read<String>('name')),
      contains('match_confidence'),
    );
  });
}
