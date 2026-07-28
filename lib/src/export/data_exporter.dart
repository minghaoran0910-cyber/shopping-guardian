import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../budget/budget_store.dart';
import '../history/decision_store.dart';
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
    final content = const JsonEncoder.withIndent('  ').convert({
      'schema_version': 2,
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
