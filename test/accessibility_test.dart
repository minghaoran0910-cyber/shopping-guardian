import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/main.dart';
import 'package:shopping_guardian/src/import/shared_text_receiver.dart';

void main() {
  testWidgets('关键页面在 200% 字号下没有溢出', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();
    expect(find.text('三步开始使用'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('先逛逛'));
    await tester.pumpAndSettle();
    expect(find.text('想买什么？'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('外观'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('桌面端可用键盘建立焦点并切换导航', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNotNull);

    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('主要页面满足标签和触控尺寸门禁', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('Android 分享文字进入后聚焦有标签的商品输入框', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    const channel = MethodChannel('test/accessibility-shared-text');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getInitialText');
          return '【京东】https://3.cn/accessibility-test';
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      ShoppingGuardianApp(
        sharedTextReceiver: SharedTextReceiver(channel: channel),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.widgetWithText(TextField, '链接或描述');
    expect(field, findsOneWidget);
    final textField = tester.widget<TextField>(field);
    expect(textField.controller?.text, contains('京东'));
    expect(textField.focusNode?.hasFocus, isTrue);
    expect(find.bySemanticsLabel('链接或描述'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('预算输入框拥有明确标签', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('改预算'));
    await tester.pumpAndSettle();

    final field = find.widgetWithText(TextField, '本月预算');
    expect(field, findsOneWidget);
    expect(
      find.descendant(of: field, matching: find.bySemanticsLabel('本月预算')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
