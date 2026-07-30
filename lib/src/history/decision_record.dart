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
    this.category,
    this.tags = const [],
    this.referencedHistory = const [],
    this.referencedPatterns = const [],
    this.referencedOwnedItems = const [],
    this.risk,
    this.confidence,
    this.budgetImpact,
    this.priceTimingEvidence,
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
  final String? category;
  final List<String> tags;
  final List<String> referencedHistory;
  final List<String> referencedPatterns;
  final List<String> referencedOwnedItems;
  final String? risk;
  final String? confidence;
  final String? budgetImpact;
  final String? priceTimingEvidence;
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
    'category': category,
    'tags': tags,
    'referencedHistory': referencedHistory,
    'referencedPatterns': referencedPatterns,
    'referencedOwnedItems': referencedOwnedItems,
    'risk': risk,
    'confidence': confidence,
    'budgetImpact': budgetImpact,
    'priceTimingEvidence': priceTimingEvidence,
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
    category: json['category']?.toString(),
    tags: (json['tags'] as List?)?.map((item) => '$item').toList() ?? const [],
    referencedHistory:
        (json['referencedHistory'] as List?)?.map((item) => '$item').toList() ??
        const [],
    referencedPatterns:
        (json['referencedPatterns'] as List?)
            ?.map((item) => '$item')
            .toList() ??
        const [],
    referencedOwnedItems:
        (json['referencedOwnedItems'] as List?)
            ?.map((item) => '$item')
            .toList() ??
        const [],
    risk: json['risk']?.toString(),
    confidence: json['confidence']?.toString(),
    budgetImpact: json['budgetImpact']?.toString(),
    priceTimingEvidence: json['priceTimingEvidence']?.toString(),
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
    String? category,
    List<String>? tags,
    bool replaceMetadata = false,
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
    category: replaceMetadata ? category : category ?? this.category,
    tags: replaceMetadata ? tags ?? const [] : tags ?? this.tags,
    referencedHistory: referencedHistory,
    referencedPatterns: referencedPatterns,
    referencedOwnedItems: referencedOwnedItems,
    risk: risk,
    confidence: confidence,
    budgetImpact: budgetImpact,
    priceTimingEvidence: priceTimingEvidence,
    alternatives: alternatives,
    events: events ?? this.events,
  );
}
