import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DecisionEvent {
  const DecisionEvent({required this.status, required this.occurredAt});

  final String status;
  final DateTime occurredAt;

  Map<String, Object?> toJson() => {
    'status': status,
    'occurredAt': occurredAt.toIso8601String(),
  };

  factory DecisionEvent.fromJson(Map<String, dynamic> json) => DecisionEvent(
    status: '${json['status']}',
    occurredAt: DateTime.parse('${json['occurredAt']}'),
  );
}

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
    this.referencedHistory = const [],
    this.risk,
    this.confidence,
    this.budgetImpact,
    this.alternatives = const [],
    this.events = const [],
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
  final List<String> referencedHistory;
  final String? risk;
  final String? confidence;
  final String? budgetImpact;
  final List<String> alternatives;
  final List<DecisionEvent> events;

  List<DecisionEvent> get effectiveEvents {
    if (events.isNotEmpty) return events;
    final legacyStatus = switch (userChoice) {
      'buy' => 'purchased',
      'wait' => 'waiting',
      'skip' => 'skipped',
      'alternative' => 'seeking_alternative',
      _ => 'analyzed',
    };
    return [
      DecisionEvent(status: 'analyzed', occurredAt: createdAt),
      if (legacyStatus != 'analyzed')
        DecisionEvent(status: legacyStatus, occurredAt: createdAt),
      if (feedback != null)
        DecisionEvent(status: 'feedback_completed', occurredAt: createdAt),
    ];
  }

  String get currentStatus => effectiveEvents.last.status;

  bool get countsAsPurchased =>
      currentStatus == 'purchased' ||
      (currentStatus == 'feedback_completed' &&
          (feedback == 'satisfied' || feedback == 'regretted'));

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
    'referencedHistory': referencedHistory,
    'risk': risk,
    'confidence': confidence,
    'budgetImpact': budgetImpact,
    'alternatives': alternatives,
    'events': events.map((event) => event.toJson()).toList(),
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
    referencedHistory:
        (json['referencedHistory'] as List?)?.map((item) => '$item').toList() ??
        const [],
    risk: json['risk']?.toString(),
    confidence: json['confidence']?.toString(),
    budgetImpact: json['budgetImpact']?.toString(),
    alternatives:
        (json['alternatives'] as List?)?.map((item) => '$item').toList() ??
        const [],
    events:
        (json['events'] as List?)
            ?.map(
              (item) => DecisionEvent.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList() ??
        const [],
  );

  DecisionRecord copyWith({String? feedback, List<DecisionEvent>? events}) =>
      DecisionRecord(
        id: id,
        itemName: itemName,
        total: total,
        verdict: verdict,
        userChoice: userChoice,
        summary: summary,
        createdAt: createdAt,
        waitUntil: waitUntil,
        feedback: feedback ?? this.feedback,
        referencedHistory: referencedHistory,
        risk: risk,
        confidence: confidence,
        budgetImpact: budgetImpact,
        alternatives: alternatives,
        events: events ?? this.events,
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
    final now = DateTime.now();
    final updated = records
        .map(
          (record) => record.id == id
              ? record.copyWith(
                  feedback: feedback,
                  events: [
                    ...record.effectiveEvents,
                    if ((feedback == 'satisfied' || feedback == 'regretted') &&
                        !record.countsAsPurchased)
                      DecisionEvent(status: 'purchased', occurredAt: now),
                    if (feedback == 'not_bought' &&
                        record.currentStatus != 'skipped')
                      DecisionEvent(status: 'skipped', occurredAt: now),
                    DecisionEvent(
                      status: 'feedback_completed',
                      occurredAt: now,
                    ),
                  ],
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

  Future<void> setStatus(
    String id,
    String status, {
    DateTime? occurredAt,
  }) async {
    const allowed = {
      'waiting',
      'intend_to_buy',
      'purchased',
      'skipped',
      'seeking_alternative',
    };
    if (!allowed.contains(status)) {
      throw ArgumentError.value(
        status,
        'status',
        'unsupported decision status',
      );
    }
    final records = await readAll();
    final updated = records
        .map(
          (record) => record.id != id || record.currentStatus == status
              ? record
              : record.copyWith(
                  events: [
                    ...record.effectiveEvents,
                    DecisionEvent(
                      status: status,
                      occurredAt: occurredAt ?? DateTime.now(),
                    ),
                  ],
                ),
        )
        .toList();
    await _writeAll(updated);
  }

  Future<void> delete(String id) async {
    final records = (await readAll()).where((record) => record.id != id);
    await _writeAll(records);
  }

  Future<void> _writeAll(Iterable<DecisionRecord> records) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      records.map((record) => jsonEncode(record.toJson())).toList(),
    );
  }
}
