import 'package:flutter/services.dart';

class LocalNotificationService {
  const LocalNotificationService({
    this.channel = const MethodChannel('shopping_guardian/notifications'),
  });
  final MethodChannel channel;

  Future<bool> schedule({
    required String id,
    required String title,
    required DateTime at,
  }) async {
    try {
      return await channel.invokeMethod<bool>('schedule', {
            'id': id,
            'title': title,
            'timestamp': at.millisecondsSinceEpoch,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> cancel(String id) async {
    try {
      await channel.invokeMethod<void>('cancel', {'id': id});
    } on MissingPluginException {
      return;
    }
  }

  Future<bool> isDelivered(String id) async {
    try {
      return await channel.invokeMethod<bool>('isDelivered', {'id': id}) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }
}
