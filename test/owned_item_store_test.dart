import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/owned/owned_item.dart';
import 'package:shopping_guardian/src/owned/owned_item_store.dart';

void main() {
  late GuardianDatabase database;
  late OwnedItemStore store;

  setUp(() {
    database = GuardianDatabase.memory();
    store = OwnedItemStore(database: database);
  });

  tearDown(() => database.close());

  test('stores, updates, and deletes manually owned items', () async {
    final now = DateTime(2026, 7, 30, 10);
    final item = OwnedItem(
      id: 'owned-1',
      name: '宁芝键盘',
      category: '数码',
      status: 'in_use',
      quantity: 1,
      notes: '办公室使用',
      purchasePrice: 699,
      createdAt: now,
      updatedAt: now,
    );
    await store.save(item);
    await store.save(
      OwnedItem(
        id: item.id,
        name: item.name,
        category: item.category,
        status: 'backup',
        quantity: 2,
        notes: item.notes,
        purchasePrice: item.purchasePrice,
        createdAt: item.createdAt,
        updatedAt: now.add(const Duration(hours: 1)),
      ),
    );

    final saved = (await store.readAll()).single;
    expect(saved.status, 'backup');
    expect(saved.quantity, 2);
    await store.delete(item.id);
    expect(await store.readAll(), isEmpty);
  });

  test('only returns current items in the exact category', () async {
    final now = DateTime(2026, 7, 30, 10);
    for (final item in [
      OwnedItem(
        id: 'active',
        name: '旧耳机',
        category: '数码',
        status: 'in_use',
        quantity: 1,
        createdAt: now,
        updatedAt: now,
      ),
      OwnedItem(
        id: 'retired',
        name: '已卖耳机',
        category: '数码',
        status: 'retired',
        quantity: 1,
        createdAt: now,
        updatedAt: now,
      ),
      OwnedItem(
        id: 'home',
        name: '台灯',
        category: '家居',
        status: 'in_use',
        quantity: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ]) {
      await store.save(item);
    }

    final relevant = await store.activeInCategory('数码');
    expect(relevant.map((item) => item.id), ['active']);
    expect(await store.activeInCategory(null), isEmpty);
  });

  test('rejects invalid status, quantity, and negative price', () async {
    final now = DateTime(2026, 7, 30, 10);
    OwnedItem item({
      String status = 'in_use',
      int quantity = 1,
      double? price,
    }) => OwnedItem(
      id: 'invalid',
      name: '商品',
      category: '数码',
      status: status,
      quantity: quantity,
      purchasePrice: price,
      createdAt: now,
      updatedAt: now,
    );

    expect(() => store.save(item(status: 'lost')), throwsArgumentError);
    expect(() => store.save(item(quantity: 0)), throwsArgumentError);
    expect(() => store.save(item(price: -1)), throwsArgumentError);
  });
}
