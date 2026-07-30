import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/analysis/analysis_request_summary.dart';
import 'package:shopping_guardian/src/analysis/price_timing_summary.dart';

void main() {
  test('summarizes exactly the fields sent to the model', () {
    const summary = AnalysisRequestSummary(
      endpoint: 'https://models.example.com/v1/chat/completions?region=cn',
      itemName: '宁芝键盘',
      price: 699,
      reason: '工作需要',
      category: '数码',
      tags: ['机械键盘', '办公'],
      monthlyBudget: 2000,
      matchedRules: ['大额商品：至少等两天'],
      relatedHistory: ['上次买键盘后使用频率很低'],
      confirmedPatterns: ['我买唱片后通常很少播放'],
      priceTiming: PriceTimingSummary.insufficient('可信价格记录不足'),
    );

    expect(summary.destination, 'models.example.com');
    expect(summary.requestBody, {
      'item_name': '宁芝键盘',
      'price': 699,
      'purchase_reason': '工作需要',
      'category': '数码',
      'tags': ['机械键盘', '办公'],
      'monthly_budget': 2000,
      'matched_rules': ['大额商品：至少等两天'],
      'minimum_rule_wait_days': null,
      'related_history': ['上次买键盘后使用频率很低'],
      'confirmed_patterns': ['我买唱片后通常很少播放'],
      'owned_items_same_category': [],
      'price_timing_evidence': {
        'status': 'insufficient',
        'scope': 'same_platform_same_item_local_device',
        'note': '可信价格记录不足',
        'trusted_observation_count': 0,
        'current': null,
        'previous_trusted': null,
        'local_30_day_low': null,
        'authority': '价格只影响现在买还是等，不能覆盖需求、预算、消费规则或已有物品判断',
      },
    });
    expect(summary.requestBody.toString(), isNot(contains('api_key')));
    expect(summary.requestBody.toString(), isNot(contains('secret')));
  });
}
