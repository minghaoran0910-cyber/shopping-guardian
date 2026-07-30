import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/export/data_exporter.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';
import 'package:shopping_guardian/src/owned/owned_item.dart';
import 'package:shopping_guardian/src/owned/owned_item_store.dart';
import 'package:shopping_guardian/src/prices/price_watch.dart';
import 'package:shopping_guardian/src/prices/price_watch_store.dart';
import 'package:shopping_guardian/src/profile/consumer_profile.dart';
import 'package:shopping_guardian/src/profile/consumer_profile_store.dart';
import 'package:shopping_guardian/src/rules/consumption_rule_store.dart';

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
        feedback: 'regretted',
        usageFrequency: 'rarely',
        satisfaction: 2,
        regretReason: '使用太少',
      ),
    );
    final savedDecision = (await const DecisionStore().readAll()).single;
    final createdAt = DateTime(2026, 7, 12, 12);
    await const PriceWatchStore().save(
      PriceWatch(
        id: 'watch-export',
        decisionId: savedDecision.id,
        itemName: '唱片',
        platform: ShoppingPlatform.taobao,
        itemId: '123456789',
        productUrl: Uri.parse('https://item.taobao.com/item.htm?id=123456789'),
        targetPrice: 280,
        createdAt: createdAt,
        lastPrice: 300,
        lastCheckedAt: createdAt,
      ),
    );
    await const PriceWatchStore().addObservation(
      PriceSnapshot(
        watchId: 'watch-export',
        observedAt: createdAt,
        price: 300,
        source: 'justoneapi',
        matchConfidence: 0.9,
      ),
    );
    await const OwnedItemStore().save(
      OwnedItem(
        id: 'owned-export',
        name: '旧耳机',
        category: '数码',
        status: 'in_use',
        quantity: 1,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
    await const ConsumptionRuleStore().saveAll([
      const ConsumptionRule(id: 'rule-1', name: '等待', description: '大额消费等两天'),
    ]);
    await const ConsumerProfileStore().save(
      ConsumerProfile(
        title: '清醒规划派',
        traits: ['先比较再决定', '重视长期使用', '愿意等待好价格'],
        reminder: '低价只是时机，不是购买理由。',
        source: 'quiz',
        updatedAt: createdAt,
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
    expect(data['schema_version'], 9);
    expect(data['monthly_budget'], 2000);
    expect(data['decisions'], hasLength(1));
    final decision = (data['decisions'] as List).single as Map<String, dynamic>;
    expect(decision['usageFrequency'], 'rarely');
    expect(decision['satisfaction'], 2);
    expect(decision['regretReason'], '使用太少');
    expect(data['rules'], hasLength(1));
    expect(data['price_watches'], hasLength(1));
    expect(data['owned_items'], hasLength(1));
    expect((data['consumer_profile'] as Map)['title'], '清醒规划派');
    final history = data['price_history'] as Map<String, dynamic>;
    expect(
      ((history['watch-export'] as List).single
          as Map<String, dynamic>)['matchConfidence'],
      0.9,
    );
    expect(history['watch-export'], hasLength(1));
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
