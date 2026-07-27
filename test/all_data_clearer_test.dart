import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/data/all_data_clearer.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/notifications/local_notification_service.dart';
import 'package:shopping_guardian/src/settings/api_key_store.dart';

class _MemoryApiKeyStore extends ApiKeyStore {
  String justOneApiKey = 'product-key';
  String modelApiKey = 'model-key';

  @override
  Future<void> writeJustOneApiToken(String value) async {
    justOneApiKey = value;
  }

  @override
  Future<void> writeModelApiKey(String value) async {
    modelApiKey = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clears preferences, API keys, and decision notifications', () async {
    final createdAt = DateTime(2026, 7, 27);
    final record = DecisionRecord(
      id: 'decision-1',
      itemName: '测试商品',
      total: 299,
      verdict: 'wait',
      userChoice: 'wait',
      summary: '先等等',
      createdAt: createdAt,
      waitUntil: createdAt.add(const Duration(days: 2)),
    );
    SharedPreferences.setMockInitialValues({
      'onboarding_seen': true,
      'theme_mode': 'dark',
      'language': 'en',
      'monthly_budget_limit': 2000.0,
      'consumption_rules_v1': <String>['{"id":"rule"}'],
      'decision_history_v1': <String>[jsonEncode(record.toJson())],
    });

    const channel = MethodChannel('test/all-data-notifications');
    final methods = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          methods.add(call.method);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final keys = _MemoryApiKeyStore();
    await AllDataClearer(
      apiKeyStore: keys,
      notificationService: const LocalNotificationService(channel: channel),
    ).clear();

    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    expect(keys.justOneApiKey, isEmpty);
    expect(keys.modelApiKey, isEmpty);
    expect(methods, ['cancelAll']);
  });
}
