import 'package:drift/drift.dart';

import '../data/guardian_database.dart';
import '../data/legacy_data_migrator.dart';
import 'decision_record.dart';

export 'decision_record.dart';

class DecisionStore {
  const DecisionStore({this.database});

  final GuardianDatabase? database;
  GuardianDatabase get _database => database ?? GuardianDatabase.instance;

  Future<List<DecisionRecord>> readAll() async {
    await LegacyDataMigrator(_database).migrate();
    final rows = await (_database.select(
      _database.decisions,
    )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).get();
    final eventRows = await (_database.select(
      _database.decisionEvents,
    )..orderBy([(row) => OrderingTerm.asc(row.position)])).get();
    final referenceRows = await (_database.select(
      _database.decisionReferences,
    )..orderBy([(row) => OrderingTerm.asc(row.position)])).get();
    final alternativeRows = await (_database.select(
      _database.decisionAlternatives,
    )..orderBy([(row) => OrderingTerm.asc(row.position)])).get();

    final eventsByDecision = <String, List<StoredDecisionEvent>>{};
    for (final event in eventRows) {
      eventsByDecision.putIfAbsent(event.decisionId, () => []).add(event);
    }
    final referencesByDecision = <String, List<StoredDecisionReference>>{};
    for (final reference in referenceRows) {
      referencesByDecision
          .putIfAbsent(reference.decisionId, () => [])
          .add(reference);
    }
    final alternativesByDecision = <String, List<StoredDecisionAlternative>>{};
    for (final alternative in alternativeRows) {
      alternativesByDecision
          .putIfAbsent(alternative.decisionId, () => [])
          .add(alternative);
    }

    return rows
        .map(
          (row) => _readRecord(
            row,
            eventsByDecision[row.id] ?? const [],
            referencesByDecision[row.id] ?? const [],
            alternativesByDecision[row.id] ?? const [],
          ),
        )
        .toList();
  }

  Future<void> add(DecisionRecord record) async {
    await LegacyDataMigrator(_database).migrate();
    await _database.transaction(() => _write(record));
  }

  Future<void> clear() async {
    await LegacyDataMigrator(_database).migrate();
    await _database.transaction(() async {
      await _database.delete(_database.decisionEvents).go();
      await _database.delete(_database.decisionReferences).go();
      await _database.delete(_database.decisionAlternatives).go();
      await _database.delete(_database.decisions).go();
    });
  }

  Future<void> setFeedback(String id, String feedback) async {
    final record = await _find(id);
    if (record == null) return;
    final now = DateTime.now();
    await _replace(
      record.copyWith(
        feedback: feedback,
        events: [
          ...record.effectiveEvents,
          if ((feedback == 'satisfied' || feedback == 'regretted') &&
              !record.countsAsPurchased)
            DecisionEvent(status: 'purchased', occurredAt: now),
          if (feedback == 'not_bought' && record.currentStatus != 'skipped')
            DecisionEvent(status: 'skipped', occurredAt: now),
          DecisionEvent(status: 'feedback_completed', occurredAt: now),
        ],
      ),
    );
  }

  Future<void> setStatus(
    String id,
    String status, {
    DateTime? occurredAt,
  }) async {
    const allowed = {
      'waiting',
      'intend_to_buy',
      'purchased',
      'skipped',
      'seeking_alternative',
    };
    if (!allowed.contains(status)) {
      throw ArgumentError.value(
        status,
        'status',
        'unsupported decision status',
      );
    }
    final record = await _find(id);
    if (record == null || record.currentStatus == status) return;
    await _replace(
      record.copyWith(
        events: [
          ...record.effectiveEvents,
          DecisionEvent(
            status: status,
            occurredAt: occurredAt ?? DateTime.now(),
          ),
        ],
      ),
    );
  }

  Future<void> delete(String id) async {
    await LegacyDataMigrator(_database).migrate();
    await (_database.delete(
      _database.decisions,
    )..where((row) => row.id.equals(id))).go();
  }

  Future<DecisionRecord?> _find(String id) async {
    final records = await readAll();
    return records.where((record) => record.id == id).firstOrNull;
  }

  Future<void> _replace(DecisionRecord record) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.decisions,
      )..where((row) => row.id.equals(record.id))).go();
      await _write(record);
    });
  }

  Future<void> _write(DecisionRecord record) async {
    final preferredId = record.id.isEmpty
        ? record.createdAt.microsecondsSinceEpoch.toString()
        : record.id;
    final id = await _database.availableDecisionId(preferredId);
    await _database
        .into(_database.decisions)
        .insert(
          DecisionsCompanion.insert(
            id: id,
            itemName: record.itemName,
            total: record.total,
            verdict: record.verdict,
            userChoice: record.userChoice,
            summary: record.summary,
            createdAt: record.createdAt,
            waitUntil: Value(record.waitUntil),
            feedback: Value(record.feedback),
            risk: Value(record.risk),
            confidence: Value(record.confidence),
            budgetImpact: Value(record.budgetImpact),
          ),
        );
    for (final (position, event) in record.events.indexed) {
      await _database
          .into(_database.decisionEvents)
          .insert(
            DecisionEventsCompanion.insert(
              decisionId: id,
              position: position,
              status: event.status,
              occurredAt: event.occurredAt,
            ),
          );
    }
    for (final (position, summary) in record.referencedHistory.indexed) {
      await _database
          .into(_database.decisionReferences)
          .insert(
            DecisionReferencesCompanion.insert(
              decisionId: id,
              position: position,
              summary: summary,
            ),
          );
    }
    for (final (position, description) in record.alternatives.indexed) {
      await _database
          .into(_database.decisionAlternatives)
          .insert(
            DecisionAlternativesCompanion.insert(
              decisionId: id,
              position: position,
              description: description,
            ),
          );
    }
  }

  DecisionRecord _readRecord(
    StoredDecision row,
    List<StoredDecisionEvent> events,
    List<StoredDecisionReference> references,
    List<StoredDecisionAlternative> alternatives,
  ) {
    return DecisionRecord(
      id: row.id,
      itemName: row.itemName,
      total: row.total,
      verdict: row.verdict,
      userChoice: row.userChoice,
      summary: row.summary,
      createdAt: row.createdAt,
      waitUntil: row.waitUntil,
      feedback: row.feedback,
      referencedHistory: references.map((item) => item.summary).toList(),
      risk: row.risk,
      confidence: row.confidence,
      budgetImpact: row.budgetImpact,
      alternatives: alternatives.map((item) => item.description).toList(),
      events: events
          .map(
            (event) => DecisionEvent(
              status: event.status,
              occurredAt: event.occurredAt,
            ),
          )
          .toList(),
    );
  }
}
