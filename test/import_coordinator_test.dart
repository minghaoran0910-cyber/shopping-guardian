import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/import/import_coordinator.dart';
import 'package:shopping_guardian/src/import/import_diagnostic_store.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';

void main() {
  late GuardianDatabase database;
  setUp(() => database = GuardianDatabase.memory());
  tearDown(() => database.close());

  SharedShoppingItem item(
    ShoppingPlatform platform,
    ShareKind kind,
    String path,
  ) => SharedShoppingItem(
    platform: platform,
    kind: kind,
    url: Uri.parse(path),
    title: '分享文字里的标题',
  );

  test('一个商品补全失败不影响同批其他商品', () async {
    final store = ImportDiagnosticStore(database: database);
    final result =
        await ImportCoordinator(
          diagnostics: store,
          jdCartLoader: (_) async => [
            item(
              ShoppingPlatform.jd,
              ShareKind.product,
              'https://item.jd.com/1.html',
            ),
          ],
          taobaoProductLoader: (_) async => throw Exception('secret raw page'),
        ).enrich([
          item(ShoppingPlatform.jd, ShareKind.collection, 'https://3.cn/list'),
          item(
            ShoppingPlatform.taobao,
            ShareKind.product,
            'https://e.tb.cn/item',
          ),
        ]);

    expect(result.items, hasLength(2));
    expect(result.items.last.title, '分享文字里的标题');
    expect(result.warnings, hasLength(1));
    final diagnostic = (await store.readAll()).single;
    expect(diagnostic.platform, 'taobao');
    expect(diagnostic.stage, 'enrich_item');
    expect(diagnostic.category, 'unexpected');
    expect(diagnostic.toJson().toString(), isNot(contains('secret')));
    expect(diagnostic.toJson().toString(), isNot(contains('e.tb.cn')));
  });

  test('淘宝购物车明确降级到截图且不丢失原始项', () async {
    final store = ImportDiagnosticStore(database: database);
    final original = item(
      ShoppingPlatform.taobao,
      ShareKind.collection,
      'https://m.tb.cn/cart?tk=secret',
    );
    final result = await ImportCoordinator(
      diagnostics: store,
    ).enrich([original]);

    expect(result.items.single, same(original));
    expect(
      result.warnings.single,
      ImportWarning.taobaoCollectionNeedsScreenshot,
    );
    expect((await store.readAll()).single.category, 'unsupported');
  });
}
