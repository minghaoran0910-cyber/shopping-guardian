import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopping_guardian/src/settings/api_key_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('writes, reads, and removes a JustOneAPI key', (tester) async {
    const store = ApiKeyStore();
    const value = 'integration-test-token';

    await store.writeJustOneApiToken(value);
    expect(await store.readJustOneApiToken(), value);

    await store.writeJustOneApiToken('');
    expect(await store.readJustOneApiToken(), isEmpty);
  });
}
