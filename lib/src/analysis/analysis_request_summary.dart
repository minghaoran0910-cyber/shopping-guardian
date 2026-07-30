import 'price_timing_summary.dart';

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
    this.minimumRuleWaitDays,
    required this.relatedHistory,
    this.confirmedPatterns = const [],
    this.ownedItems = const [],
    this.priceTiming = const PriceTimingSummary.insufficient('尚未监测此商品'),
  });

  final String endpoint;
  final String itemName;
  final double price;
  final String? reason;
  final String? category;
  final List<String> tags;
  final double? monthlyBudget;
  final List<String> matchedRules;
  final int? minimumRuleWaitDays;
  final List<String> relatedHistory;
  final List<String> confirmedPatterns;
  final List<String> ownedItems;
  final PriceTimingSummary priceTiming;

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
    'minimum_rule_wait_days': minimumRuleWaitDays,
    'related_history': relatedHistory,
    'confirmed_patterns': confirmedPatterns,
    'owned_items_same_category': ownedItems,
    'price_timing_evidence': priceTiming.toJson(),
  };
}
