import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';

void main() {
  test(
    'migrates a v1 decisions table to structured feedback columns',
    () async {
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

      expect(database.schemaVersion, 2);
      expect(
        names,
        containsAll(['usage_frequency', 'satisfaction', 'regret_reason']),
      );
    },
  );
}
