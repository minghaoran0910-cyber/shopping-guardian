import 'package:drift/drift.dart';

import '../data/guardian_database.dart';
import 'owned_item.dart';

class OwnedItemStore {
  const OwnedItemStore({this.database});

  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<List<OwnedItem>> readAll() async {
    final rows = await (_database.select(
      _database.ownedItems,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).get();
    return rows.map(_fromRow).toList();
  }

  Future<List<OwnedItem>> activeInCategory(String? category) async {
    final normalized = category?.trim();
    if (normalized == null || normalized.isEmpty) return const [];
    final rows =
        await (_database.select(_database.ownedItems)..where(
              (row) =>
                  row.category.equals(normalized) &
                  row.status.isIn(const ['in_use', 'backup']),
            ))
            .get();
    return rows.map(_fromRow).toList();
  }

  Future<void> save(OwnedItem item) {
    _validate(item);
    return _database
        .into(_database.ownedItems)
        .insertOnConflictUpdate(
          OwnedItemsCompanion.insert(
            id: item.id,
            name: item.name.trim(),
            category: item.category.trim(),
            status: item.status,
            quantity: Value(item.quantity),
            notes: Value(_nullable(item.notes)),
            purchasePrice: Value(item.purchasePrice),
            acquiredAt: Value(item.acquiredAt),
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          ),
        );
  }

  Future<void> delete(String id) => (_database.delete(
    _database.ownedItems,
  )..where((row) => row.id.equals(id))).go();

  void _validate(OwnedItem item) {
    if (item.name.trim().isEmpty) {
      throw ArgumentError.value(item.name, 'name', 'must not be empty');
    }
    if (item.category.trim().isEmpty) {
      throw ArgumentError.value(item.category, 'category', 'must not be empty');
    }
    if (!OwnedItemTemplates.statuses.contains(item.status)) {
      throw ArgumentError.value(item.status, 'status', 'unsupported');
    }
    if (item.quantity < 1 || item.quantity > 999) {
      throw ArgumentError.value(item.quantity, 'quantity', 'must be 1..999');
    }
    if (item.purchasePrice != null &&
        (!item.purchasePrice!.isFinite || item.purchasePrice! < 0)) {
      throw ArgumentError.value(
        item.purchasePrice,
        'purchasePrice',
        'must be non-negative',
      );
    }
  }

  static String? _nullable(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  OwnedItem _fromRow(StoredOwnedItem row) => OwnedItem(
    id: row.id,
    name: row.name,
    category: row.category,
    status: row.status,
    quantity: row.quantity,
    notes: row.notes,
    purchasePrice: row.purchasePrice,
    acquiredAt: row.acquiredAt,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
