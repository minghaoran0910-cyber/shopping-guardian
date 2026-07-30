import 'package:drift/drift.dart';

import '../data/guardian_database.dart';
import '../import/share_parser.dart';
import 'price_watch.dart';

class PriceWatchStore {
  const PriceWatchStore({this.database});

  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<List<PriceWatch>> readAll() async {
    final rows = await (_database.select(
      _database.priceWatches,
    )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).get();
    return rows.map(_fromRow).toList();
  }

  Future<void> save(PriceWatch watch) => _database
      .into(_database.priceWatches)
      .insertOnConflictUpdate(
        PriceWatchesCompanion.insert(
          id: watch.id,
          decisionId: watch.decisionId,
          itemName: watch.itemName,
          platform: watch.platform.name,
          itemId: watch.itemId,
          productUrl: watch.productUrl.toString(),
          targetPrice: watch.targetPrice,
          createdAt: watch.createdAt,
          enabled: Value(watch.enabled),
          lastPrice: Value(watch.lastPrice),
          lastCheckedAt: Value(watch.lastCheckedAt),
          lastError: Value(watch.lastError),
          notifiedAt: Value(watch.notifiedAt),
        ),
      );

  Future<void> addObservation(PriceSnapshot observation) async {
    await _database
        .into(_database.priceObservations)
        .insert(
          PriceObservationsCompanion.insert(
            watchId: observation.watchId,
            observedAt: observation.observedAt,
            price: observation.price,
            source: observation.source,
            matchConfidence: Value(observation.matchConfidence),
          ),
        );
  }

  Future<List<PriceSnapshot>> history(String watchId) async {
    final rows =
        await (_database.select(_database.priceObservations)
              ..where((row) => row.watchId.equals(watchId))
              ..orderBy([(row) => OrderingTerm.asc(row.observedAt)]))
            .get();
    return rows
        .map(
          (row) => PriceSnapshot(
            watchId: row.watchId,
            observedAt: row.observedAt,
            price: row.price,
            source: row.source,
            matchConfidence: row.matchConfidence,
          ),
        )
        .toList();
  }

  Future<void> delete(String id) => (_database.delete(
    _database.priceWatches,
  )..where((row) => row.id.equals(id))).go();

  PriceWatch _fromRow(StoredPriceWatch row) => PriceWatch(
    id: row.id,
    decisionId: row.decisionId,
    itemName: row.itemName,
    platform: ShoppingPlatform.values.firstWhere(
      (value) => value.name == row.platform,
      orElse: () => ShoppingPlatform.unknown,
    ),
    itemId: row.itemId,
    productUrl: Uri.parse(row.productUrl),
    targetPrice: row.targetPrice,
    createdAt: row.createdAt,
    enabled: row.enabled,
    lastPrice: row.lastPrice,
    lastCheckedAt: row.lastCheckedAt,
    lastError: row.lastError,
    notifiedAt: row.notifiedAt,
  );
}
