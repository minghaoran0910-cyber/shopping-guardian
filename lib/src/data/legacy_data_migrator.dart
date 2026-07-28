import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../history/decision_record.dart';
import '../rules/consumption_rule.dart';
import 'guardian_database.dart';

class LegacyDataMigrator {
  const LegacyDataMigrator(this.database);

  static const _marker = 'legacy_shared_preferences_v1_migrated';
  static const _decisionKey = 'decision_history_v1';
  static const _budgetKey = 'monthly_budget_limit';
  static const _rulesKey = 'consumption_rules_v1';

  final GuardianDatabase database;

  Future<void> migrate() async {
    final completed = await (database.select(
      database.appValues,
    )..where((row) => row.key.equals(_marker))).getSingleOrNull();
    if (completed != null) return;

    final preferences = await SharedPreferences.getInstance();
    final decisions = preferences.getStringList(_decisionKey) ?? const [];
    final rules = preferences.getStringList(_rulesKey) ?? const [];
    final budget = preferences.getDouble(_budgetKey);

    await database.transaction(() async {
      final completedInsideTransaction = await (database.select(
        database.appValues,
      )..where((row) => row.key.equals(_marker))).getSingleOrNull();
      if (completedInsideTransaction != null) return;

      for (final raw in decisions) {
        try {
          await _insertDecision(
            DecisionRecord.fromJson(
              Map<String, dynamic>.from(jsonDecode(raw) as Map),
            ),
          );
        } on Object catch (error) {
          await _quarantine(_decisionKey, raw, error);
        }
      }
      for (final raw in rules) {
        try {
          await _insertRule(
            ConsumptionRule.fromJson(
              Map<String, dynamic>.from(jsonDecode(raw) as Map),
            ),
          );
        } on Object catch (error) {
          await _quarantine(_rulesKey, raw, error);
        }
      }
      if (budget != null) {
        await database
            .into(database.appValues)
            .insert(
              AppValuesCompanion.insert(
                key: _budgetKey,
                value: budget.toString(),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
      await database
          .into(database.appValues)
          .insert(
            AppValuesCompanion.insert(key: _marker, value: 'true'),
            mode: InsertMode.insertOrReplace,
          );
    });

    await preferences.remove(_decisionKey);
    await preferences.remove(_rulesKey);
    await preferences.remove(_budgetKey);
  }

  Future<void> _insertDecision(DecisionRecord record) async {
    final preferredId = record.id.isEmpty
        ? record.createdAt.microsecondsSinceEpoch.toString()
        : record.id;
    final id = await database.availableDecisionId(preferredId);
    await database
        .into(database.decisions)
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
            usageFrequency: Value(record.usageFrequency),
            satisfaction: Value(record.satisfaction),
            regretReason: Value(record.regretReason),
            risk: Value(record.risk),
            confidence: Value(record.confidence),
            budgetImpact: Value(record.budgetImpact),
          ),
        );
    for (final (position, event) in record.events.indexed) {
      await database
          .into(database.decisionEvents)
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
      await database
          .into(database.decisionReferences)
          .insert(
            DecisionReferencesCompanion.insert(
              decisionId: id,
              position: position,
              summary: summary,
            ),
          );
    }
    for (final (position, description) in record.alternatives.indexed) {
      await database
          .into(database.decisionAlternatives)
          .insert(
            DecisionAlternativesCompanion.insert(
              decisionId: id,
              position: position,
              description: description,
            ),
          );
    }
  }

  Future<void> _insertRule(ConsumptionRule rule) => database
      .into(database.consumptionRules)
      .insert(
        ConsumptionRulesCompanion.insert(
          id: rule.id,
          name: rule.name,
          description: rule.description,
          minimumAmount: Value(rule.minimumAmount),
          waitDays: Value(rule.waitDays),
          enabled: Value(rule.enabled),
        ),
      );

  Future<void> _quarantine(String sourceKey, String raw, Object error) =>
      database
          .into(database.migrationQuarantine)
          .insert(
            MigrationQuarantineCompanion.insert(
              sourceKey: sourceKey,
              rawValue: raw,
              error: error.runtimeType.toString(),
              quarantinedAt: DateTime.now(),
            ),
          );
}
