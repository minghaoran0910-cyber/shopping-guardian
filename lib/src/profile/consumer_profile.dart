class ConsumerProfile {
  const ConsumerProfile({
    required this.title,
    required this.traits,
    required this.reminder,
    required this.source,
    required this.updatedAt,
  });

  static const disclaimer = '娱乐性消费总结，不是心理测评或科学结论';
  static const projectUrl = 'github.com/minghaoran0910-cyber/shopping-guardian';

  final String title;
  final List<String> traits;
  final String reminder;
  final String source;
  final DateTime updatedAt;

  ConsumerProfile copyWith({
    String? title,
    List<String>? traits,
    String? reminder,
  }) => ConsumerProfile(
    title: title ?? this.title,
    traits: traits ?? this.traits,
    reminder: reminder ?? this.reminder,
    source: source,
    updatedAt: DateTime.now(),
  );

  Map<String, Object?> toJson() => {
    'title': title,
    'traits': traits,
    'reminder': reminder,
    'source': source,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory ConsumerProfile.fromJson(Map<String, dynamic> json) {
    final traits =
        (json['traits'] as List?)
            ?.whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .take(3)
            .toList() ??
        const [];
    final profile = ConsumerProfile(
      title: '${json['title'] ?? ''}'.trim(),
      traits: traits,
      reminder: '${json['reminder'] ?? ''}'.trim(),
      source: '${json['source'] ?? ''}'.trim(),
      updatedAt: DateTime.tryParse('${json['updated_at']}') ?? DateTime.now(),
    );
    if (!profile.isValid) throw const FormatException();
    return profile;
  }

  bool get isValid =>
      title.isNotEmpty &&
      title.length <= 24 &&
      traits.length == 3 &&
      traits.every((item) => item.length <= 60) &&
      reminder.isNotEmpty &&
      reminder.length <= 100 &&
      const {'evidence', 'quiz'}.contains(source);

  Map<String, Object?> get shareCardPayload => {
    'title': title,
    'traits': traits,
    'reminder': reminder,
    'disclaimer': disclaimer,
    'app_name': '购物守护者',
    'project_url': projectUrl,
  };
}
