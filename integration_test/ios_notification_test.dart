import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopping_guardian/src/notifications/local_notification_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('schedules and delivers an iOS cooldown notification', (
    tester,
  ) async {
    const service = LocalNotificationService();
    const id = 'ios-integration-notification';
    await service.cancel(id);
    expect(
      await service.schedule(
        id: id,
        title: '通知集成测试商品',
        at: DateTime.now().add(const Duration(seconds: 3)),
      ),
      isTrue,
    );
    await Future<void>.delayed(const Duration(seconds: 6));
    expect(await service.isDelivered(id), isTrue);
    await service.cancel(id);
  });

  testWidgets('cancels an iOS cooldown notification', (tester) async {
    const service = LocalNotificationService();
    const id = 'ios-integration-cancel';
    expect(
      await service.schedule(
        id: id,
        title: '应被取消的商品',
        at: DateTime.now().add(const Duration(seconds: 3)),
      ),
      isTrue,
    );
    await service.cancel(id);
    await Future<void>.delayed(const Duration(seconds: 5));
    expect(await service.isDelivered(id), isFalse);
  });
}
