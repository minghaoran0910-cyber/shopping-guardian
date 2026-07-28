import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/history/purchase_feedback_dialog.dart';

void main() {
  testWidgets('returns structured purchase feedback', (tester) async {
    PurchaseFeedback? result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: const [Locale('zh'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showDialog<PurchaseFeedback>(
                context: context,
                builder: (_) => const PurchaseFeedbackDialog(),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(find.text('使用频率'), findsOneWidget);
    expect(find.text('满意度'), findsOneWidget);

    await tester.tap(find.text('保存反馈'));
    await tester.pumpAndSettle();
    expect(result?.outcome, 'satisfied');
    expect(result?.usageFrequency, 'weekly');
    expect(result?.satisfaction, 4);
  });
}
