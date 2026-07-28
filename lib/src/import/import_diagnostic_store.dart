import 'dart:convert';

import '../data/guardian_database.dart';
import 'import_diagnostic.dart';

class ImportDiagnosticStore {
  const ImportDiagnosticStore({this.database});

  static const key = 'import_diagnostics_v1';
  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<List<ImportDiagnostic>> readAll() async {
    final row = await (_database.select(
      _database.appValues,
    )..where((item) => item.key.equals(key))).getSingleOrNull();
    if (row == null) return const [];
    try {
      return (jsonDecode(row.value) as List)
          .map(
            (item) => ImportDiagnostic.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on Object {
      return const [];
    }
  }

  Future<void> add(ImportDiagnostic diagnostic) async {
    final updated = [...await readAll(), diagnostic];
    final limited = updated.length <= 100
        ? updated
        : updated.sublist(updated.length - 100);
    await _database
        .into(_database.appValues)
        .insertOnConflictUpdate(
          AppValuesCompanion.insert(
            key: key,
            value: jsonEncode(limited.map((item) => item.toJson()).toList()),
          ),
        );
  }

  Future<void> clear() async {
    await (_database.delete(
      _database.appValues,
    )..where((item) => item.key.equals(key))).go();
  }
}
