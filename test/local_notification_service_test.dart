import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/notifications/local_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('schedules and cancels by decision id', () async {
    const channel = MethodChannel('test/notifications');
    final methods = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          methods.add(call.method);
          return call.method == 'schedule';
        });
    const service = LocalNotificationService(channel: channel);
    expect(
      await service.schedule(id: 'one', title: '唱片', at: DateTime(2026)),
      isTrue,
    );
    await service.cancel('one');
    expect(methods, ['schedule', 'cancel']);
  });
}
