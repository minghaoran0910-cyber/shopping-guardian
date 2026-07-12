import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ConsumptionRule {
  const ConsumptionRule({
    required this.id,
    required this.name,
    required this.description,
    this.minimumAmount,
    this.waitDays,
    this.enabled = true,
  });
  final String id;
  final String name;
  final String description;
  final double? minimumAmount;
  final int? waitDays;
  final bool enabled;

  bool matches(double amount) =>
      enabled && (minimumAmount == null || amount >= minimumAmount!);
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'minimumAmount': minimumAmount,
    'waitDays': waitDays,
    'enabled': enabled,
  };
  factory ConsumptionRule.fromJson(Map<String, dynamic> json) =>
      ConsumptionRule(
        id: '${json['id']}',
        name: '${json['name']}',
        description: '${json['description']}',
        minimumAmount: (json['minimumAmount'] as num?)?.toDouble(),
        waitDays: (json['waitDays'] as num?)?.toInt(),
        enabled: json['enabled'] != false,
      );
  ConsumptionRule copyWith({bool? enabled}) => ConsumptionRule(
    id: id,
    name: name,
    description: description,
    minimumAmount: minimumAmount,
    waitDays: waitDays,
    enabled: enabled ?? this.enabled,
  );
}

class ConsumptionRuleStore {
  const ConsumptionRuleStore();
  static const _key = 'consumption_rules_v1';

  Future<List<ConsumptionRule>> readAll() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_key) ?? const [])
        .map((item) => ConsumptionRule.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> saveAll(List<ConsumptionRule> rules) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      rules.map((rule) => jsonEncode(rule.toJson())).toList(),
    );
  }

  Future<List<ConsumptionRule>> matching(double amount) async =>
      (await readAll()).where((rule) => rule.matches(amount)).toList();
}
