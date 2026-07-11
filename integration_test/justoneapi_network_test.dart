import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopping_guardian/src/import/justoneapi_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads a JD product from JustOneAPI', (tester) async {
    const token = String.fromEnvironment('JUSTONEAPI_TEST_TOKEN');
    expect(token, isNotEmpty, reason: 'Pass JUSTONEAPI_TEST_TOKEN at runtime');

    final product = await const JustOneApiClient(
      token: token,
    ).loadJdProduct('63081885510');

    expect(product.itemId, '63081885510');
    expect(product.title, isNotEmpty);
    expect(product.price, isNotNull);
  });
}
