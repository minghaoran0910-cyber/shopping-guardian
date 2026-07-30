class AnalysisRequestSummary {
  const AnalysisRequestSummary({
    required this.endpoint,
    required this.itemName,
    required this.price,
    required this.reason,
    this.category,
    this.tags = const [],
    required this.monthlyBudget,
    required this.matchedRules,
    required this.relatedHistory,
    this.confirmedPatterns = const [],
    this.ownedItems = const [],
  });

  final String endpoint;
  final String itemName;
  final double price;
  final String? reason;
  final String? category;
  final List<String> tags;
  final double? monthlyBudget;
  final List<String> matchedRules;
  final List<String> relatedHistory;
  final List<String> confirmedPatterns;
  final List<String> ownedItems;

  String get destination {
    final uri = Uri.tryParse(endpoint);
    return uri?.host.isNotEmpty == true ? uri!.host : endpoint;
  }

  Map<String, Object?> get requestBody => {
    'item_name': itemName,
    'price': price,
    'purchase_reason': reason,
    'category': category,
    'tags': tags,
    'monthly_budget': monthlyBudget,
    'matched_rules': matchedRules,
    'related_history': relatedHistory,
    'confirmed_patterns': confirmedPatterns,
    'owned_items_same_category': ownedItems,
  };
}
