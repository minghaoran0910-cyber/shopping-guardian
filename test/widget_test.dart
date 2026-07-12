import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_guardian/main.dart';

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
}
