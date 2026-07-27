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
