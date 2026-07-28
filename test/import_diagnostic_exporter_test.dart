import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/import/import_diagnostic.dart';
import 'package:shopping_guardian/src/import/import_diagnostic_exporter.dart';
import 'package:shopping_guardian/src/import/import_diagnostic_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('导出内容保持脱敏', () async {
    final database = GuardianDatabase.memory();
    addTearDown(database.close);
    final store = ImportDiagnosticStore(database: database);
    await store.add(
      ImportDiagnostic(
        platform: 'jd',
        stage: 'extract_collection',
        category: 'timeout',
        occurredAt: DateTime.utc(2026, 7, 28),
      ),
    );
    const channel = MethodChannel('test/import_diagnostics');
    String? exported;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          exported = (call.arguments as Map)['content'] as String;
          return true;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    expect(
      await ImportDiagnosticExporter(store: store, channel: channel).export(),
      isTrue,
    );
    final json = jsonDecode(exported!) as Map<String, dynamic>;
    expect(json['events'], hasLength(1));
    expect(exported, isNot(contains('http')));
    expect(exported, isNot(contains('token')));
    expect(exported, isNot(contains('title')));
  });
}
