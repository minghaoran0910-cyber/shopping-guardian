import 'local_notification_service.dart';

class FeedbackReminderService {
  const FeedbackReminderService({
    this.notifications = const LocalNotificationService(),
  });

  static const defaultDelay = Duration(days: 7);
  final LocalNotificationService notifications;

  String notificationId(String decisionId) => '${decisionId}_feedback';

  Future<bool> schedule({
    required String decisionId,
    required String title,
    DateTime? purchasedAt,
  }) => notifications.schedule(
    id: notificationId(decisionId),
    title: title,
    at: (purchasedAt ?? DateTime.now()).add(defaultDelay),
  );

  Future<void> cancel(String decisionId) =>
      notifications.cancel(notificationId(decisionId));
}
