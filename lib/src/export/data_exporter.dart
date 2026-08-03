import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../budget/budget_store.dart';
import '../history/decision_store.dart';
import '../owned/owned_item_store.dart';
import '../patterns/pattern_store.dart';
import '../prices/price_watch_store.dart';
import '../profile/consumer_profile_store.dart';
import '../rules/consumption_rule_store.dart';

class DataExporter {
  const DataExporter({
    this.channel = const MethodChannel('shopping_guardian/file_export'),
  });
  final MethodChannel channel;

  Future<bool> export() async {
    final preferences = await SharedPreferences.getInstance();
    final records = await const DecisionStore().readAll();
    final rules = await const ConsumptionRuleStore().readAll();
    final budget = await const BudgetStore().snapshot();
    final patterns = await const PatternStore().readAll();
    final ownedItems = await const OwnedItemStore().readAll();
    final priceWatches = await const PriceWatchStore().readAll();
    final consumerProfile = await const ConsumerProfileStore().read();
    final priceHistory = <String, Object?>{};
    for (final watch in priceWatches) {
      priceHistory[watch.id] = (await const PriceWatchStore().history(watch.id))
          .map(
            (observation) => {
              'observedAt': observation.observedAt.toIso8601String(),
              'price': observation.price,
              'source': observation.source,
              'matchConfidence': observation.matchConfidence,
            },
          )
          .toList();
    }
    final content = const JsonEncoder.withIndent('  ').convert({
      'schema_version': 10,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'monthly_budget': budget.limit,
      'model': {
        'endpoint':
            preferences.getString('model_endpoint') ??
            preferences.getString('model_base_url'),
        'name': preferences.getString('model_name'),
        'structured_output':
            preferences.getBool('model_structured_output') ?? true,
      },
      'decisions': records.map((record) => record.toJson()).toList(),
      'rules': rules.map((rule) => rule.toJson()).toList(),
      'personal_patterns': patterns.map((pattern) => pattern.toJson()).toList(),
      'owned_items': ownedItems.map((item) => item.toJson()).toList(),
      'price_watches': priceWatches.map((watch) => watch.toJson()).toList(),
      'price_history': priceHistory,
      'consumer_profile': consumerProfile?.toJson(),
    });
    try {
      return await channel.invokeMethod<bool>('saveJson', {
            'content': content,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }
}
