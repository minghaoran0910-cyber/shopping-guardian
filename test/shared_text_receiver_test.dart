import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_guardian/src/import/shared_text_receiver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('delivers initial Android shared text once', () async {
    const channel = MethodChannel('test/shared_text');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getInitialText');
          return '  【京东】https://3.cn/example  ';
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final received = <String>[];
    final receiver = SharedTextReceiver(channel: channel);
    await receiver.start(received.add);

    expect(received, ['【京东】https://3.cn/example']);
    receiver.stop();
  });
}
