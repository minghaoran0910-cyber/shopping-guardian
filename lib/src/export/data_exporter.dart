import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../history/decision_store.dart';

class DataExporter {
  const DataExporter({
    this.channel = const MethodChannel('shopping_guardian/file_export'),
  });
  final MethodChannel channel;

  Future<bool> export() async {
    final preferences = await SharedPreferences.getInstance();
    final records = await const DecisionStore().readAll();
    final content = const JsonEncoder.withIndent('  ').convert({
      'schema_version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'monthly_budget': preferences.getDouble('monthly_budget_limit') ?? 0,
      'model': {
        'base_url': preferences.getString('model_base_url'),
        'name': preferences.getString('model_name'),
      },
      'decisions': records.map((record) => record.toJson()).toList(),
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
