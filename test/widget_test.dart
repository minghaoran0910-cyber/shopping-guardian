import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_guardian/main.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/import/shared_text_receiver.dart';

void main() {
  testWidgets('shows privacy notice on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();
    expect(find.text('先说清楚数据去哪儿'), findsOneWidget);
    expect(find.text('我知道了'), findsOneWidget);
    await tester.tap(find.text('我知道了'));
    await tester.pumpAndSettle();
    expect(find.text('先说清楚数据去哪儿'), findsNothing);
  });

  testWidgets('shows the local-first analysis workspace', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());

    expect(find.text('想买什么？'), findsOneWidget);
    expect(find.text('商品信息'), findsOneWidget);
    expect(find.text('本月预算'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
  });

  testWidgets('switches to the cooldown destination', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('稍后再看'));
    await tester.pumpAndSettle();

    expect(find.text('这里还空着'), findsOneWidget);
  });

  testWidgets('changes language and theme from settings', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('外观'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('previews items parsed from shared shopping text', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.enterText(
      find.byType(TextField).first,
      '【京东】https://3.cn/2V-chiOQ?jkl=@EDoxt4DBLAN@ MU5104 「vivo X300 蔡司2亿超级主摄」',
    );
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();

    expect(find.text('认出了 1 项'), findsOneWidget);
    expect(find.text('vivo X300 蔡司2亿超级主摄'), findsOneWidget);
    expect(find.text('京东 · 单品'), findsOneWidget);

    await tester.tap(find.text('继续分析'));
    await tester.pumpAndSettle();
    expect(find.text('买它是为了什么？'), findsOneWidget);
    expect(find.text('购买理由'), findsOneWidget);
    expect(find.text('本月剩余预算（选填）'), findsOneWidget);
  });

  testWidgets('previews a manually entered product', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('手动填写'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '商品名称 *'), '手动商品');
    await tester.enterText(find.widgetWithText(TextField, '价格 *'), '88');
    await tester.enterText(find.widgetWithText(TextField, '平台（选填）'), '淘宝');
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    expect(find.text('认出了 1 项'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('手动商品'),
      ),
      findsOneWidget,
    );
    expect(find.text('淘宝 · 单品 · ¥88'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('修改商品'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, '商品名称'), '改过的商品');
    await tester.enterText(find.widgetWithText(TextField, '价格'), '99');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('改过的商品'), findsOneWidget);
    expect(find.text('淘宝 · 单品 · ¥99'), findsOneWidget);
  });

  testWidgets('previews Taobao and JD items received from Android sharing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const channel = MethodChannel('test/widget_shared_text');
    const sharedText = '''
【淘宝】7天无理由退货 [https://e.tb.cn/h.826Ec69frH3tGlL?tk=4OaXgGvWPKX](https://e.tb.cn/h.826Ec69frH3tGlL?tk=4OaXgGvWPKX) MF278 「IZ乐队 - 路过旧天堂书店 12寸2LP半透明棕色胶+画册套盒现货包邮」
点击链接直接打开 或者 淘宝搜索直接打开
【京东】[https://3.cn/-2WCEI8M?jkl=@YCMEy7nNyRx](https://3.cn/-2WCEI8M?jkl=@YCMEy7nNyRx)@ CA1507 「宁芝静电容轴三模可编程键盘」
点击链接直接打开 或者复制文案打开京东
''';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getInitialText') {
            return sharedText;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(
      ShoppingGuardianApp(
        sharedTextReceiver: SharedTextReceiver(channel: channel),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller?.text, contains('https://e.tb.cn/'));
    expect(field.controller?.text, contains('https://3.cn/'));

    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();

    expect(find.text('认出了 2 项'), findsOneWidget);
    expect(find.text('IZ乐队 - 路过旧天堂书店 12寸2LP半透明棕色胶+画册套盒现货包邮'), findsOneWidget);
    expect(find.text('宁芝静电容轴三模可编程键盘'), findsOneWidget);
  });

  testWidgets('changes a decision status and shows its timeline', (
    tester,
  ) async {
    const notificationChannel = MethodChannel(
      'shopping_guardian/notifications',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationChannel, (_) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notificationChannel, null),
    );
    final createdAt = DateTime(2026, 7, 24, 10);
    SharedPreferences.setMockInitialValues({
      'onboarding_seen': true,
      'decision_history_v1': [
        jsonEncode({
          'id': 'one',
          'itemName': '宁芝静电容键盘',
          'total': 699,
          'verdict': 'wait',
          'userChoice': 'wait',
          'summary': '先冷静两天',
          'createdAt': createdAt.toIso8601String(),
          'events': [
            {'status': 'analyzed', 'occurredAt': createdAt.toIso8601String()},
            {'status': 'waiting', 'occurredAt': createdAt.toIso8601String()},
          ],
        }),
      ],
    });
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('记录'));
    await tester.pumpAndSettle();

    expect(find.text('宁芝静电容键盘'), findsOneWidget);
    expect(find.text('冷静中'), findsWidgets);
    await tester.tap(find.text('宁芝静电容键盘'));
    await tester.pumpAndSettle();
    expect(find.text('状态时间线'), findsOneWidget);
    expect(find.textContaining('冷静中 ·'), findsOneWidget);

    await tester.tap(find.text('修改状态'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(SimpleDialog),
        matching: find.text('已购买'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SimpleDialog), findsNothing);
    expect(
      (await const DecisionStore().readAll()).single.currentStatus,
      'purchased',
    );
    expect(
      find.descendant(of: find.byType(Card), matching: find.text('已购买')),
      findsOneWidget,
    );
  });
}
