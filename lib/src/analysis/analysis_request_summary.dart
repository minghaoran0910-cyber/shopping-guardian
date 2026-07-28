class AnalysisRequestSummary {
  const AnalysisRequestSummary({
    required this.endpoint,
    required this.itemName,
    required this.price,
    required this.reason,
    required this.monthlyBudget,
    required this.matchedRules,
    required this.relatedHistory,
  });

  final String endpoint;
  final String itemName;
  final double price;
  final String? reason;
  final double? monthlyBudget;
  final List<String> matchedRules;
  final List<String> relatedHistory;

  String get destination {
    final uri = Uri.tryParse(endpoint);
    return uri?.host.isNotEmpty == true ? uri!.host : endpoint;
  }

  Map<String, Object?> get requestBody => {
    'item_name': itemName,
    'price': price,
    'purchase_reason': reason,
    'monthly_budget': monthlyBudget,
    'matched_rules': matchedRules,
    'related_history': relatedHistory,
  };
}
