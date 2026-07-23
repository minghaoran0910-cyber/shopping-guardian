import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopping_guardian/src/import/jd_product_importer.dart';
import 'package:shopping_guardian/src/import/justoneapi_client.dart';
import 'package:shopping_guardian/src/import/taobao_product_importer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const unusedDetails = JustOneApiClient(token: 'not-used-for-resolution');

  testWidgets('resolves the reported Taobao share link', (tester) async {
    final itemId = await const TaobaoProductImporter(
      productDetails: unusedDetails,
    ).resolveItemId(
      Uri.parse('https://e.tb.cn/h.826Ec69frH3tGlL?tk=4OaXgGvWPKX'),
    );

    expect(itemId, '692813957349');
  });

  testWidgets('resolves the reported JD share link', (tester) async {
    final itemId = await const JdProductImporter(
      productDetails: unusedDetails,
    ).resolveItemId(
      Uri.parse('https://3.cn/-2WCEI8M?jkl=@YCMEy7nNyRx'),
    );

    expect(itemId, '57764460866');
  });
}
