import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DecisionRecord {
  const DecisionRecord({
    required this.itemName,
    required this.total,
    required this.verdict,
    required this.userChoice,
    required this.summary,
    required this.createdAt,
  });
  final String itemName;
  final double total;
  final String verdict;
  final String userChoice;
  final String summary;
  final DateTime createdAt;

  Map<String, Object> toJson() => {
    'itemName': itemName,
    'total': total,
    'verdict': verdict,
    'userChoice': userChoice,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
  };
  factory DecisionRecord.fromJson(Map<String, dynamic> json) => DecisionRecord(
    itemName: '${json['itemName']}',
    total: (json['total'] as num).toDouble(),
    verdict: '${json['verdict']}',
    userChoice: '${json['userChoice']}',
    summary: '${json['summary']}',
    createdAt: DateTime.parse('${json['createdAt']}'),
  );
}

class DecisionStore {
  const DecisionStore();
  static const _key = 'decision_history_v1';

  Future<List<DecisionRecord>> readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_key) ?? const [];
    return raw.map((item) => DecisionRecord.fromJson(jsonDecode(item))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> add(DecisionRecord record) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_key) ?? <String>[];
    await preferences.setStringList(_key, [
      jsonEncode(record.toJson()),
      ...raw,
    ]);
  }
}
