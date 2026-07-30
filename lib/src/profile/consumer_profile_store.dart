import 'dart:convert';

import '../data/guardian_database.dart';
import 'consumer_profile.dart';

class ConsumerProfileStore {
  const ConsumerProfileStore({this.database});

  static const key = 'consumer_profile_v1';
  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<ConsumerProfile?> read() async {
    final row = await (_database.select(
      _database.appValues,
    )..where((item) => item.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      return ConsumerProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.value) as Map),
      );
    } on Object {
      return null;
    }
  }

  Future<void> save(ConsumerProfile profile) async {
    if (!profile.isValid) throw const FormatException('invalid profile');
    await _database
        .into(_database.appValues)
        .insertOnConflictUpdate(
          AppValuesCompanion.insert(
            key: key,
            value: jsonEncode(profile.toJson()),
          ),
        );
  }
}
