import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/analysis/analysis_request_review_dialog.dart';
import 'package:shopping_guardian/src/analysis/analysis_request_summary.dart';
import 'package:shopping_guardian/src/analysis/price_timing_summary.dart';

void main() {
  testWidgets('shows the model payload and can cancel sending', (tester) async {
    const summary = AnalysisRequestSummary(
      endpoint: 'https://models.example.com/v1/chat/completions',
      itemName: '宁芝键盘',
      price: 699,
      reason: '工作需要',
      monthlyBudget: 2000,
      matchedRules: ['大额商品：至少等两天'],
      relatedHistory: ['上次买键盘后使用频率很低'],
      ownedItems: ['旧键盘｜仍在使用｜数量 1'],
      priceTiming: PriceTimingSummary.insufficient('可信价格记录不足'),
    );
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: const [Locale('zh'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (_) =>
                    const AnalysisRequestReviewDialog(summary: summary),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.text('发送前核对'), findsOneWidget);
    expect(find.textContaining('models.example.com'), findsOneWidget);
    expect(find.text('宁芝键盘'), findsOneWidget);
    expect(find.text('工作需要'), findsOneWidget);
    expect(find.text('上次买键盘后使用频率很低'), findsOneWidget);
    expect(find.text('同类已有物品'), findsOneWidget);
    expect(find.text('旧键盘｜仍在使用｜数量 1'), findsOneWidget);
    expect(find.text('价格时机证据'), findsOneWidget);
    expect(find.textContaining('数据不足，不能判断入手时机'), findsOneWidget);
    expect(find.textContaining('API Key 只用于请求头'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
