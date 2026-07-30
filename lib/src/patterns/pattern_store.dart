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

  Future<List<String>> readConfirmedTexts({int limit = 10}) async {
    if (limit <= 0) return const [];
    return (await readAll())
        .where((pattern) => pattern.status == 'confirmed')
        .map((pattern) => pattern.text.trim())
        .where((text) => text.isNotEmpty)
        .take(limit)
        .toList();
  }

  Future<void> save(PersonalPattern pattern) async {
    await saveAll([pattern]);
  }

  Future<void> saveAll(List<PersonalPattern> patterns) async {
    if (patterns.isEmpty) return;
    final values = await readAll();
    final replacementIds = patterns.map((pattern) => pattern.id).toSet();
    final updated = [
      ...values.where((item) => !replacementIds.contains(item.id)),
      ...patterns,
    ];
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
