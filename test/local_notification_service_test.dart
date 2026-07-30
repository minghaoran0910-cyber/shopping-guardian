import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/notifications/local_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('schedules and cancels by decision id', () async {
    const channel = MethodChannel('test/notifications');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'schedule';
        });
    const service = LocalNotificationService(channel: channel);
    expect(
      await service.schedule(
        id: 'one',
        title: '唱片已到 ¥199.00',
        at: DateTime(2026),
        kind: LocalNotificationKind.price,
      ),
      isTrue,
    );
    await service.cancel('one');
    await service.cancelAll();
    expect(calls.map((call) => call.method), [
      'schedule',
      'cancel',
      'cancelAll',
    ]);
    expect(calls.first.arguments, {
      'id': 'one',
      'title': '唱片已到 ¥199.00',
      'timestamp': DateTime(2026).millisecondsSinceEpoch,
      'kind': 'price',
    });
  });
}
