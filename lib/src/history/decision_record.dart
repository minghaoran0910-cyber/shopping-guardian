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
    this.usageFrequency,
    this.satisfaction,
    this.regretReason,
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
  final String? usageFrequency;
  final int? satisfaction;
  final String? regretReason;
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
    'usageFrequency': usageFrequency,
    'satisfaction': satisfaction,
    'regretReason': regretReason,
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
    usageFrequency: json['usageFrequency']?.toString(),
    satisfaction: (json['satisfaction'] as num?)?.toInt(),
    regretReason: json['regretReason']?.toString(),
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

  DecisionRecord copyWith({
    String? feedback,
    String? usageFrequency,
    int? satisfaction,
    String? regretReason,
    bool replaceFeedbackDetails = false,
    List<DecisionEvent>? events,
  }) => DecisionRecord(
    id: id,
    itemName: itemName,
    total: total,
    verdict: verdict,
    userChoice: userChoice,
    summary: summary,
    createdAt: createdAt,
    waitUntil: waitUntil,
    feedback: feedback ?? this.feedback,
    usageFrequency: replaceFeedbackDetails
        ? usageFrequency
        : usageFrequency ?? this.usageFrequency,
    satisfaction: replaceFeedbackDetails
        ? satisfaction
        : satisfaction ?? this.satisfaction,
    regretReason: replaceFeedbackDetails
        ? regretReason
        : regretReason ?? this.regretReason,
    referencedHistory: referencedHistory,
    risk: risk,
    confidence: confidence,
    budgetImpact: budgetImpact,
    alternatives: alternatives,
    events: events ?? this.events,
  );
}
