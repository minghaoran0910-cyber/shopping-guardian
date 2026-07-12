import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopping_guardian/main.dart';

void main() {
  testWidgets('desktop workspace visual baseline', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/desktop_workspace.png'),
    );
  });

  testWidgets('settings visual baseline', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings.png'),
    );
  });

  testWidgets('import preview visual baseline', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShoppingGuardianApp());
    await tester.enterText(
      find.byType(TextField).first,
      '【京东】https://3.cn/2V-chiOQ 「vivo X300 蔡司2亿超级主摄」',
    );
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/import_preview.png'),
    );
  });
}
