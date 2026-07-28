class ImportDiagnostic {
  const ImportDiagnostic({
    required this.platform,
    required this.stage,
    required this.category,
    required this.occurredAt,
  });

  final String platform;
  final String stage;
  final String category;
  final DateTime occurredAt;

  Map<String, Object?> toJson() => {
    'platform': platform,
    'stage': stage,
    'category': category,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
  };

  factory ImportDiagnostic.fromJson(Map<String, dynamic> json) =>
      ImportDiagnostic(
        platform: '${json['platform']}',
        stage: '${json['stage']}',
        category: '${json['category']}',
        occurredAt: DateTime.parse('${json['occurred_at']}'),
      );
}
