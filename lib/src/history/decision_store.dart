import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DecisionRecord {
  const DecisionRecord({
    this.id = '',
    required this.itemName,
    required this.total,
    required this.verdict,
    required this.userChoice,
    required this.summary,
    required this.createdAt,
    this.waitUntil,
    this.feedback,
  });
  final String id;
  final String itemName;
  final double total;
  final String verdict;
  final String userChoice;
  final String summary;
  final DateTime createdAt;
  final DateTime? waitUntil;
  final String? feedback;

  Map<String, Object?> toJson() => {
    'id': id.isEmpty ? createdAt.microsecondsSinceEpoch.toString() : id,
    'itemName': itemName,
    'total': total,
    'verdict': verdict,
    'userChoice': userChoice,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
    'waitUntil': waitUntil?.toIso8601String(),
    'feedback': feedback,
  };
  factory DecisionRecord.fromJson(Map<String, dynamic> json) => DecisionRecord(
    id: '${json['id'] ?? json['createdAt']}',
    itemName: '${json['itemName']}',
    total: (json['total'] as num).toDouble(),
    verdict: '${json['verdict']}',
    userChoice: '${json['userChoice']}',
    summary: '${json['summary']}',
    createdAt: DateTime.parse('${json['createdAt']}'),
    waitUntil: json['waitUntil'] == null
        ? null
        : DateTime.parse('${json['waitUntil']}'),
    feedback: json['feedback']?.toString(),
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

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }

  Future<void> setFeedback(String id, String feedback) async {
    final records = await readAll();
    final updated = records
        .map(
          (record) => record.id == id
              ? DecisionRecord(
                  id: record.id,
                  itemName: record.itemName,
                  total: record.total,
                  verdict: record.verdict,
                  userChoice: record.userChoice,
                  summary: record.summary,
                  createdAt: record.createdAt,
                  waitUntil: record.waitUntil,
                  feedback: feedback,
                )
              : record,
        )
        .toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      updated.map((record) => jsonEncode(record.toJson())).toList(),
    );
  }
}
