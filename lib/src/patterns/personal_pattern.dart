class PatternEvidence {
  const PatternEvidence({
    required this.decisionId,
    required this.summary,
    required this.supportsPattern,
  });

  final String decisionId;
  final String summary;
  final bool supportsPattern;

  Map<String, Object?> toJson() => {
    'decisionId': decisionId,
    'summary': summary,
    'supportsPattern': supportsPattern,
  };

  factory PatternEvidence.fromJson(Map<String, dynamic> json) =>
      PatternEvidence(
        decisionId: '${json['decisionId']}',
        summary: '${json['summary']}',
        supportsPattern: json['supportsPattern'] == true,
      );
}

class PersonalPattern {
  const PersonalPattern({
    required this.id,
    required this.text,
    required this.status,
    required this.evidence,
    this.updatedAt,
  });

  final String id;
  final String text;
  final String status;
  final List<PatternEvidence> evidence;
  final DateTime? updatedAt;

  PersonalPattern copyWith({String? text, String? status}) => PersonalPattern(
    id: id,
    text: text ?? this.text,
    status: status ?? this.status,
    evidence: evidence,
    updatedAt: DateTime.now(),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'status': status,
    'evidence': evidence.map((item) => item.toJson()).toList(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory PersonalPattern.fromJson(
    Map<String, dynamic> json,
  ) => PersonalPattern(
    id: '${json['id']}',
    text: '${json['text']}',
    status: '${json['status']}',
    evidence: (json['evidence'] as List? ?? const [])
        .map(
          (item) =>
              PatternEvidence.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse('${json['updatedAt']}'),
  );
}
