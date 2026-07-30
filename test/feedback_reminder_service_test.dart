import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/notifications/feedback_reminder_service.dart';
import 'package:shopping_guardian/src/notifications/local_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('uses a separate id and schedules seven days after purchase', () async {
    const channel = MethodChannel('test/feedback-reminder');
    MethodCall? invocation;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          invocation = call;
          return true;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    const service = FeedbackReminderService(
      notifications: LocalNotificationService(channel: channel),
    );
    final purchasedAt = DateTime(2026, 7, 28, 10);

    expect(
      await service.schedule(
        decisionId: 'one',
        title: '回顾一下：键盘',
        purchasedAt: purchasedAt,
      ),
      isTrue,
    );

    expect(invocation?.method, 'schedule');
    expect(invocation?.arguments, {
      'id': 'one_feedback',
      'title': '回顾一下：键盘',
      'timestamp': purchasedAt
          .add(const Duration(days: 7))
          .millisecondsSinceEpoch,
      'kind': 'feedback',
    });

    await service.cancel('one');
    expect(invocation?.method, 'cancel');
    expect(invocation?.arguments, {'id': 'one_feedback'});
  });
}
