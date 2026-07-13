import 'package:flutter/services.dart';

class SharedTextReceiver {
  SharedTextReceiver({
    this.channel = const MethodChannel('shopping_guardian/shared_text'),
  });

  final MethodChannel channel;

  Future<void> start(ValueChanged<String> onText) async {
    channel.setMethodCallHandler((call) async {
      if (call.method != 'onSharedText') return;
      final text = call.arguments as String?;
      if (text != null && text.trim().isNotEmpty) onText(text.trim());
    });
    try {
      final initial = await channel.invokeMethod<String>('getInitialText');
      if (initial != null && initial.trim().isNotEmpty) onText(initial.trim());
    } on MissingPluginException {
      // Desktop and widget tests do not provide the Android share channel.
    }
  }

  void stop() => channel.setMethodCallHandler(null);
}
