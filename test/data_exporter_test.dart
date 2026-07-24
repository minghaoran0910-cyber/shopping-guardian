import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/export/data_exporter.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exports decisions without API keys', () async {
    SharedPreferences.setMockInitialValues({
      'monthly_budget_limit': 2000.0,
      'model_base_url': 'https://example.com/v1',
      'model_name': 'test-model',
      'model_api_key': 'must-not-export',
      'justoneapi_token': 'must-not-export',
    });
    await const DecisionStore().add(
      DecisionRecord(
        itemName: '唱片',
        total: 323,
        verdict: 'wait',
        userChoice: 'wait',
        summary: '等等',
        createdAt: DateTime(2026, 7, 12),
      ),
    );
    const channel = MethodChannel('test/export');
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

    expect(await const DataExporter(channel: channel).export(), isTrue);
    final data = jsonDecode(exported!) as Map<String, dynamic>;
    expect(data['monthly_budget'], 2000);
    expect(data['decisions'], hasLength(1));
    expect(exported, isNot(contains('must-not-export')));
    expect(exported, isNot(contains('api_key')));
  });

  test(
    'returns false when file export is unavailable on the platform',
    () async {
      SharedPreferences.setMockInitialValues({});

      expect(
        await const DataExporter(
          channel: MethodChannel('test/export_unavailable'),
        ).export(),
        isFalse,
      );
    },
  );
}
