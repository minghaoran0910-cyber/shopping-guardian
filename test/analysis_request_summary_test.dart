import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/analysis/analysis_request_summary.dart';

void main() {
  test('summarizes exactly the fields sent to the model', () {
    const summary = AnalysisRequestSummary(
      endpoint: 'https://models.example.com/v1/chat/completions?region=cn',
      itemName: '宁芝键盘',
      price: 699,
      reason: '工作需要',
      monthlyBudget: 2000,
      matchedRules: ['大额商品：至少等两天'],
      relatedHistory: ['上次买键盘后使用频率很低'],
    );

    expect(summary.destination, 'models.example.com');
    expect(summary.requestBody, {
      'item_name': '宁芝键盘',
      'price': 699,
      'purchase_reason': '工作需要',
      'monthly_budget': 2000,
      'matched_rules': ['大额商品：至少等两天'],
      'related_history': ['上次买键盘后使用频率很低'],
    });
    expect(summary.requestBody.toString(), isNot(contains('api_key')));
    expect(summary.requestBody.toString(), isNot(contains('secret')));
  });
}
