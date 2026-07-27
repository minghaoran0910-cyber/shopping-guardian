import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/local_notification_service.dart';
import '../settings/api_key_store.dart';

class AllDataClearer {
  const AllDataClearer({
    this.apiKeyStore = const ApiKeyStore(),
    this.notificationService = const LocalNotificationService(),
  });

  final ApiKeyStore apiKeyStore;
  final LocalNotificationService notificationService;

  Future<void> clear() async {
    try {
      await notificationService.cancelAll();
    } on PlatformException {
      // Data removal must still succeed if notifications are unavailable.
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await apiKeyStore.writeJustOneApiToken('');
    await apiKeyStore.writeModelApiKey('');
  }
}
