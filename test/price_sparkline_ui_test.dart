import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/main.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';
import 'package:shopping_guardian/src/prices/price_watch.dart';
import 'package:shopping_guardian/src/prices/price_watch_store.dart';

void main() {
  testWidgets('shows sparkline and manipulation warning on cooldown page',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Seed a price watch with manipulation pattern data.
    const store = PriceWatchStore();
    const watchId = 'sparkline-test-watch';
    await store.delete(watchId);
    addTearDown(() => store.delete(watchId));

    final now = DateTime.now();
    await store.save(PriceWatch(
      id: watchId,
      decisionId: 'sparkline-test-decision',
      itemName: '先涨后降测试商品',
      platform: ShoppingPlatform.jd,
      itemId: '999888777',
      productUrl: Uri.parse('https://item.jd.com/999888777.html'),
      targetPrice: 80,
      createdAt: now.subtract(const Duration(days: 15)),
    ));

    // Insert manipulation pattern: 100 → 105 → 150 → 102
    final prices = [
      (100.0, now.subtract(const Duration(days: 10))),
      (105.0, now.subtract(const Duration(days: 7))),
      (150.0, now.subtract(const Duration(days: 4))),
      (102.0, now.subtract(const Duration(hours: 2))),
    ];
    for (final (price, at) in prices) {
      await store.addObservation(PriceSnapshot(
        watchId: watchId,
        observedAt: at,
        price: price,
        source: 'justoneapi',
        matchConfidence: 0.9,
      ));
    }

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();

    // Navigate to cooldown page.
    await tester.tap(find.text('稍后再看'));
    await tester.pumpAndSettle();

    // Verify the watch item appears.
    expect(find.text('先涨后降测试商品'), findsOneWidget);

    // Verify sparkline is rendered (CustomPaint widget).
    expect(find.byType(CustomPaint), findsWidgets);

    // Verify manipulation warning text appears.
    expect(find.textContaining('所谓的折扣可能不是真的便宜'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('no sparkline or warning when insufficient data',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const store = PriceWatchStore();
    const watchId = 'no-sparkline-watch';
    await store.delete(watchId);
    addTearDown(() => store.delete(watchId));

    final now = DateTime.now();
    await store.save(PriceWatch(
      id: watchId,
      decisionId: 'no-sparkline-decision',
      itemName: '数据不足商品',
      platform: ShoppingPlatform.jd,
      itemId: '111222333',
      productUrl: Uri.parse('https://item.jd.com/111222333.html'),
      targetPrice: 50,
      createdAt: now.subtract(const Duration(days: 5)),
    ));

    // Only one snapshot — not enough for sparkline or manipulation.
    await store.addObservation(PriceSnapshot(
      watchId: watchId,
      observedAt: now.subtract(const Duration(hours: 1)),
      price: 60,
      source: 'justoneapi',
      matchConfidence: 0.9,
    ));

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('稍后再看'));
    await tester.pumpAndSettle();

    expect(find.text('数据不足商品'), findsOneWidget);
    // No manipulation warning.
    expect(find.textContaining('所谓的折扣可能不是真的便宜'), findsNothing);

    expect(tester.takeException(), isNull);
  });
}
