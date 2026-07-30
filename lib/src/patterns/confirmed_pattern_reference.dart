class ConfirmedPatternReference {
  const ConfirmedPatternReference({
    required this.id,
    required this.text,
    required this.supportingEvidence,
    required this.contraryEvidence,
  });

  final String id;
  final String text;
  final List<String> supportingEvidence;
  final List<String> contraryEvidence;

  Map<String, Object?> toJson() => {
    'pattern_id': id,
    'text': text,
    'supporting_evidence': supportingEvidence,
    'contrary_evidence': contraryEvidence,
  };

  String get auditText {
    final lines = <String>[text];
    lines.addAll(supportingEvidence.map((item) => '支持：$item'));
    lines.addAll(contraryEvidence.map((item) => '反例：$item'));
    return lines.join('\n');
  }
}
