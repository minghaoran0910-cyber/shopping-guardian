import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_guardian/main.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';
import 'package:shopping_guardian/src/import/shared_text_receiver.dart';
import 'package:shopping_guardian/src/owned/owned_item_store.dart';
import 'package:shopping_guardian/src/prices/price_watch.dart';
import 'package:shopping_guardian/src/prices/price_watch_store.dart';

void main() {
  testWidgets('shows setup choices on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();
    expect(find.text('三步开始使用'), findsOneWidget);
    expect(find.textContaining('JustOneAPI'), findsOneWidget);
    expect(find.textContaining('只有 AI 分析需要模型'), findsOneWidget);
    expect(find.text('先逛逛'), findsOneWidget);
    await tester.tap(find.text('先逛逛'));
    await tester.pumpAndSettle();
    expect(find.text('三步开始使用'), findsNothing);
  });

  testWidgets('opens settings from first-run setup', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('去设置'));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsWidgets);
    expect(find.text('模型'), findsOneWidget);
    expect(find.text('JustOneAPI'), findsWidgets);
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

  testWidgets('saves a monthly budget without breaking dialog teardown', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('改预算'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1000');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('¥ 1000'), findsWidgets);
    await tester.tap(find.text('改预算'));
    await tester.pumpAndSettle();
    expect(find.text('设置本月预算'), findsOneWidget);
  });

  testWidgets('switches to the cooldown destination', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('稍后再看'));
    await tester.pumpAndSettle();

    expect(find.text('这里还空着'), findsOneWidget);
  });

  testWidgets('shows traceable price evidence and local low', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    const watchId = 'widget-price-evidence';
    const unknownWatchId = 'widget-price-unknown';
    const store = PriceWatchStore();
    await store.delete(watchId);
    await store.delete(unknownWatchId);
    addTearDown(() async {
      await store.delete(watchId);
      await store.delete(unknownWatchId);
    });
    final now = DateTime.now();
    await store.save(
      PriceWatch(
        id: watchId,
        decisionId: 'widget-price-decision',
        itemName: '证据测试耳机',
        platform: ShoppingPlatform.jd,
        itemId: '123456789',
        productUrl: Uri.parse('https://item.jd.com/123456789.html'),
        targetPrice: 450,
        createdAt: now,
        lastPrice: 480,
      ),
    );
    await store.addObservation(
      PriceSnapshot(
        watchId: watchId,
        observedAt: now.subtract(const Duration(hours: 7)),
        price: 500,
        source: 'justoneapi',
        matchConfidence: 0.9,
      ),
    );
    await store.save(
      PriceWatch(
        id: unknownWatchId,
        decisionId: 'widget-price-unknown-decision',
        itemName: '证据不足的商品',
        platform: ShoppingPlatform.jd,
        itemId: '987654321',
        productUrl: Uri.parse('https://item.jd.com/987654321.html'),
        targetPrice: 300,
        createdAt: now,
      ),
    );
    await store.addObservation(
      PriceSnapshot(
        watchId: unknownWatchId,
        observedAt: now.subtract(const Duration(hours: 1)),
        price: 299,
        source: 'justoneapi',
        matchConfidence: 0.4,
      ),
    );
    await store.addObservation(
      PriceSnapshot(
        watchId: watchId,
        observedAt: now.subtract(const Duration(hours: 1)),
        price: 480,
        source: 'justoneapi',
        matchConfidence: 0.9,
      ),
    );

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('稍后再看'));
    await tester.pumpAndSettle();

    expect(find.text('证据测试耳机'), findsOneWidget);
    expect(find.textContaining('当前价：¥480.00 · JustOneAPI'), findsOneWidget);
    expect(
      find.textContaining('参考价（上次记录）：¥500.00 · JustOneAPI'),
      findsOneWidget,
    );
    expect(find.textContaining('本机 30 天低价：¥480.00'), findsOneWidget);
    expect(find.text('证据不足的商品'), findsOneWidget);
    expect(find.textContaining('当前价：不知道'), findsOneWidget);
    expect(find.textContaining('参考价（上次记录）：不知道'), findsOneWidget);
    expect(find.textContaining('本机 30 天低价：不知道'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    expect(find.text('导入数据'), findsOneWidget);
    expect(find.text('服务预设'), findsOneWidget);
    expect(find.text('请求 JSON 输出'), findsOneWidget);
    expect(find.text('隐私与外部请求'), findsOneWidget);
    expect(find.textContaining('最多 5 条相关历史摘要'), findsOneWidget);
    expect(find.textContaining('JSON 导出没有额外加密'), findsOneWidget);
    for (final label in ['Base URL 或完整接口地址', 'API Key（选填）', '模型名称']) {
      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, label),
      );
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.textCapitalization, TextCapitalization.none);
    }
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
    expect(find.text('需核对'), findsOneWidget);

    await tester.tap(find.text('继续分析'));
    await tester.pumpAndSettle();
    expect(find.text('买它是为了什么？'), findsOneWidget);
    expect(find.text('购买理由'), findsOneWidget);
    expect(find.text('本月剩余预算（选填）'), findsOneWidget);
    expect(find.text('分类（选填）'), findsOneWidget);
    expect(find.text('标签（选填）'), findsOneWidget);
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
    expect(find.text('信息完整'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('修改商品'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, '商品名称'), '改过的商品');
    await tester.enterText(find.widgetWithText(TextField, '价格'), '99');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('改过的商品'), findsOneWidget);
    expect(find.text('淘宝 · 单品 · ¥99'), findsOneWidget);
    expect(find.text('已核对'), findsOneWidget);
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

    await tester.tap(find.text('继续分析'));
    await tester.pumpAndSettle();
    expect(find.text('第 1 件，共 2 件'), findsOneWidget);
    final analysisDialog = find.byType(AlertDialog).last;
    expect(
      find.descendant(
        of: analysisDialog,
        matching: find.textContaining('IZ乐队 - 路过旧天堂书店'),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: analysisDialog,
        matching: find.textContaining('宁芝静电容轴三模可编程键盘'),
      ),
      findsNothing,
    );

    await tester.tap(find.text('返回').last);
    await tester.pumpAndSettle();
    expect(find.text('认出了 2 项'), findsOneWidget);

    await tester.tap(find.byTooltip('不分析这件').first);
    await tester.pumpAndSettle();
    expect(find.text('认出了 1 项'), findsOneWidget);
    final previewDialog = find.byType(AlertDialog).last;
    expect(
      find.descendant(
        of: previewDialog,
        matching: find.textContaining('IZ乐队 - 路过旧天堂书店'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: previewDialog, matching: find.text('宁芝静电容轴三模可编程键盘')),
      findsOneWidget,
    );
  });

  testWidgets('changes a decision status and shows its timeline', (
    tester,
  ) async {
    const notificationChannel = MethodChannel(
      'shopping_guardian/notifications',
    );
    final notificationCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationChannel, (call) async {
          notificationCalls.add(call);
          return call.method == 'schedule';
        });
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
    expect(
      notificationCalls.any(
        (call) =>
            call.method == 'schedule' &&
            (call.arguments as Map)['id'] == 'one_feedback',
      ),
      isTrue,
    );
  });

  testWidgets('shows purchased records in the personal item library', (
    tester,
  ) async {
    final createdAt = DateTime(2026, 7, 28, 10);
    SharedPreferences.setMockInitialValues({
      'onboarding_seen': true,
      'decision_history_v1': [
        jsonEncode({
          'id': 'owned',
          'itemName': '宁芝键盘',
          'total': 699,
          'verdict': 'buy',
          'userChoice': 'buy',
          'summary': '适合办公',
          'createdAt': createdAt.toIso8601String(),
          'category': '数码',
          'tags': ['办公', '键盘'],
          'events': [
            {'status': 'purchased', 'occurredAt': createdAt.toIso8601String()},
          ],
        }),
      ],
    });
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('习惯'));
    await tester.pumpAndSettle();

    expect(find.text('我的物品'), findsOneWidget);
    expect(find.text('宁芝键盘'), findsOneWidget);
    expect(find.text('数码 · 办公 · 键盘'), findsOneWidget);
    await tester.tap(find.text('宁芝键盘'));
    await tester.pumpAndSettle();
    expect(find.textContaining('来自 2026-07-28 10:00 的决策记录'), findsOneWidget);
  });

  testWidgets('adds a manually owned item from a category template', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('习惯'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加一件'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '物品名称 *'), '我的旧耳机');
    await tester.pump();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('我的旧耳机'), findsOneWidget);
    expect(find.textContaining('数码 · 仍在使用'), findsOneWidget);
  });

  testWidgets('previews and imports a historical purchase list', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('习惯'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('导入购买清单'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('purchase-list-input')),
      '历史耳机 | 数码 | 仍在使用 | 899 | 2023-06-01 | 通勤使用\n'
      '退货键盘 | 数码 | 已退货 | 499 | 2024-01-02',
    );
    await tester.tap(find.text('解析并预览'));
    await tester.pumpAndSettle();

    expect(find.text('核对后再导入'), findsOneWidget);
    expect(find.text('历史耳机'), findsOneWidget);
    expect(find.text('退货键盘'), findsOneWidget);
    expect(find.text('导入 2 件'), findsOneWidget);
    await tester.tap(find.text('导入 2 件'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final items = await const OwnedItemStore().readAll();
    final imported = items.where(
      (item) => item.name == '历史耳机' || item.name == '退货键盘',
    );
    expect(imported, hasLength(2));
    expect(
      imported.singleWhere((item) => item.name == '历史耳机').status,
      'in_use',
    );
    expect(
      imported.singleWhere((item) => item.name == '退货键盘').status,
      'returned',
    );
  });

  testWidgets('reviews and edits a locally OCRed order screenshot', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const channel = MethodChannel('shopping_guardian/cart_ocr');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'pickAndRecognize');
          return ['交易成功', 'OCR错字耳机', '¥899', '实付款 ¥899'];
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.text('习惯'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('订单截图'));
    await tester.pumpAndSettle();

    expect(find.text('核对后再导入'), findsOneWidget);
    expect(find.text('OCR错字耳机'), findsOneWidget);
    await tester.tap(find.byTooltip('修改这一项'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('purchase-draft-name')),
      '修正后的耳机',
    );
    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();
    expect(find.text('修正后的耳机'), findsOneWidget);
    await tester.tap(find.text('导入 1 件'));
    await tester.pumpAndSettle();

    final items = await const OwnedItemStore().readAll();
    final imported = items.singleWhere((item) => item.name == '修正后的耳机');
    expect(imported.status, 'unknown');
    expect(imported.purchasePrice, 899);
  });
}
