import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopping_guardian/src/notifications/local_notification_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('schedules an Android cooldown notification', (tester) async {
    final scheduled = await const LocalNotificationService().schedule(
      id: 'android-integration-notification',
      title: '通知集成测试商品',
      at: DateTime.now().add(const Duration(seconds: 5)),
    );
    expect(scheduled, isTrue);
    await Future<void>.delayed(const Duration(seconds: 8));
    expect(
      await const LocalNotificationService().isDelivered(
        'android-integration-notification',
      ),
      isTrue,
    );
    await const LocalNotificationService().cancel(
      'android-integration-notification',
    );
  });

  testWidgets('cancels an Android cooldown notification', (tester) async {
    const service = LocalNotificationService();
    final scheduled = await service.schedule(
      id: 'android-integration-cancel',
      title: '应被取消的商品',
      at: DateTime.now().add(const Duration(seconds: 5)),
    );
    expect(scheduled, isTrue);
    await service.cancel('android-integration-cancel');
    await Future<void>.delayed(const Duration(seconds: 7));
    expect(await service.isDelivered('android-integration-cancel'), isFalse);
  });
}
