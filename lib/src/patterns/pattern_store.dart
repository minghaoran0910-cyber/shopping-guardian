import 'dart:convert';

import '../data/guardian_database.dart';
import 'personal_pattern.dart';

class PatternStore {
  const PatternStore({this.database});

  static const key = 'personal_patterns_v1';
  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<List<PersonalPattern>> readAll() async {
    final row = await (_database.select(
      _database.appValues,
    )..where((item) => item.key.equals(key))).getSingleOrNull();
    if (row == null) return const [];
    try {
      return (jsonDecode(row.value) as List)
          .map(
            (item) => PersonalPattern.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on Object {
      return const [];
    }
  }

  Future<void> save(PersonalPattern pattern) async {
    final values = await readAll();
    final updated = [...values.where((item) => item.id != pattern.id), pattern];
    await _database
        .into(_database.appValues)
        .insertOnConflictUpdate(
          AppValuesCompanion.insert(
            key: key,
            value: jsonEncode(updated.map((item) => item.toJson()).toList()),
          ),
        );
  }

  Future<void> delete(String id) async {
    final updated = (await readAll()).where((item) => item.id != id).toList();
    await _database
        .into(_database.appValues)
        .insertOnConflictUpdate(
          AppValuesCompanion.insert(
            key: key,
            value: jsonEncode(updated.map((item) => item.toJson()).toList()),
          ),
        );
  }
}
