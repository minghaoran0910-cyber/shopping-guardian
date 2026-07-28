import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';

import '../data/guardian_database.dart';
import '../data/legacy_data_migrator.dart';
import '../history/decision_record.dart';
import '../patterns/pattern_store.dart';
import '../patterns/personal_pattern.dart';
import '../rules/consumption_rule.dart';

enum DataImportMode { merge, replace }

class DataImportException implements Exception {
  const DataImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DataImportPreview {
  const DataImportPreview({
    required this.schemaVersion,
    required this.decisions,
    required this.rules,
    required this.monthlyBudget,
    required this.decisionConflicts,
    required this.ruleConflicts,
    required this.containsModelConfiguration,
    required this.containsRules,
    this.personalPatterns = const [],
  });

  final int schemaVersion;
  final List<DecisionRecord> decisions;
  final List<ConsumptionRule> rules;
  final double? monthlyBudget;
  final int decisionConflicts;
  final int ruleConflicts;
  final bool containsModelConfiguration;
  final bool containsRules;
  final List<PersonalPattern> personalPatterns;
}

class DataImportResult {
  const DataImportResult({
    required this.importedDecisions,
    required this.importedRules,
    required this.skippedConflicts,
    required this.budgetImported,
  });

  final int importedDecisions;
  final int importedRules;
  final int skippedConflicts;
  final bool budgetImported;
}

typedef JsonFilePicker = Future<String?> Function();

class DataImporter {
  DataImporter({GuardianDatabase? database, JsonFilePicker? pickFile})
    : _database = database ?? GuardianDatabase.instance,
      _pickFile = pickFile ?? _pickJsonFile;

  static const _budgetKey = 'monthly_budget_limit';
  static const _maximumFileBytes = 10 * 1024 * 1024;

  final GuardianDatabase _database;
  final JsonFilePicker _pickFile;

  Future<DataImportPreview?> pickAndPreview() async {
    final content = await _pickFile();
    if (content == null) return null;
    return preview(content);
  }

  Future<DataImportPreview> preview(String content) async {
    if (utf8.encode(content).length > _maximumFileBytes) {
      throw const DataImportException('导入文件不能超过 10 MB');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw const DataImportException('这不是有效的 JSON 文件');
    }
    if (decoded is! Map) {
      throw const DataImportException('导入文件的顶层必须是 JSON 对象');
    }
    final document = Map<String, dynamic>.from(decoded);
    final version = document['schema_version'];
    if (version is! int || version < 1 || version > 4) {
      throw const DataImportException('不支持这个数据版本，请先升级应用');
    }

    final decisions = _parseDecisions(document['decisions']);
    final rules = _parseRules(document['rules'], version);
    final budget = _parseBudget(document['monthly_budget']);
    final patterns = _parsePatterns(document['personal_patterns'], version);
    await LegacyDataMigrator(_database).migrate();

    final existingDecisionIds =
        (await _database.select(_database.decisions).get())
            .map((row) => row.id)
            .toSet();
    final existingRuleIds =
        (await _database.select(_database.consumptionRules).get())
            .map((row) => row.id)
            .toSet();

    return DataImportPreview(
      schemaVersion: version,
      decisions: List.unmodifiable(decisions),
      rules: List.unmodifiable(rules),
      monthlyBudget: budget,
      decisionConflicts: decisions
          .where((record) => existingDecisionIds.contains(record.id))
          .length,
      ruleConflicts: rules
          .where((rule) => existingRuleIds.contains(rule.id))
          .length,
      containsModelConfiguration: document['model'] is Map,
      containsRules: version >= 2,
      personalPatterns: patterns,
    );
  }

  Future<DataImportResult> apply(
    DataImportPreview preview,
    DataImportMode mode,
  ) async {
    await LegacyDataMigrator(_database).migrate();
    return _database.transaction(() async {
      if (mode == DataImportMode.replace) {
        await _database.delete(_database.decisionEvents).go();
        await _database.delete(_database.decisionReferences).go();
        await _database.delete(_database.decisionPatternReferences).go();
        await _database.delete(_database.decisionAlternatives).go();
        await _database.delete(_database.decisions).go();
        if (preview.containsRules) {
          await _database.delete(_database.consumptionRules).go();
        }
        await (_database.delete(
          _database.appValues,
        )..where((row) => row.key.equals(_budgetKey))).go();
        await (_database.delete(
          _database.appValues,
        )..where((row) => row.key.equals(PatternStore.key))).go();
      }

      final existingDecisionIds =
          (await _database.select(_database.decisions).get())
              .map((row) => row.id)
              .toSet();
      final existingRuleIds =
          (await _database.select(_database.consumptionRules).get())
              .map((row) => row.id)
              .toSet();
      var importedDecisions = 0;
      var importedRules = 0;
      var skippedConflicts = 0;

      for (final record in preview.decisions) {
        if (existingDecisionIds.contains(record.id)) {
          skippedConflicts++;
          continue;
        }
        await _insertDecision(record);
        existingDecisionIds.add(record.id);
        importedDecisions++;
      }
      for (final rule in preview.rules) {
        if (existingRuleIds.contains(rule.id)) {
          skippedConflicts++;
          continue;
        }
        await _insertRule(rule);
        existingRuleIds.add(rule.id);
        importedRules++;
      }

      var budgetImported = false;
      if (preview.monthlyBudget != null) {
        final existingBudget = await (_database.select(
          _database.appValues,
        )..where((row) => row.key.equals(_budgetKey))).getSingleOrNull();
        if (mode == DataImportMode.replace || existingBudget == null) {
          await _database
              .into(_database.appValues)
              .insert(
                AppValuesCompanion.insert(
                  key: _budgetKey,
                  value: preview.monthlyBudget!.toString(),
                ),
                mode: InsertMode.insertOrReplace,
              );
          budgetImported = true;
        }
      }
      if (preview.personalPatterns.isNotEmpty) {
        final existing = mode == DataImportMode.merge
            ? await PatternStore(database: _database).readAll()
            : const <PersonalPattern>[];
        final merged = {
          for (final pattern in existing) pattern.id: pattern,
          for (final pattern in preview.personalPatterns) pattern.id: pattern,
        }.values.toList();
        await _database
            .into(_database.appValues)
            .insert(
              AppValuesCompanion.insert(
                key: PatternStore.key,
                value: jsonEncode(
                  merged.map((pattern) => pattern.toJson()).toList(),
                ),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      return DataImportResult(
        importedDecisions: importedDecisions,
        importedRules: importedRules,
        skippedConflicts: skippedConflicts,
        budgetImported: budgetImported,
      );
    });
  }

  List<DecisionRecord> _parseDecisions(Object? value) {
    if (value is! List) {
      throw const DataImportException('缺少 decisions 数组');
    }
    final records = <DecisionRecord>[];
    final ids = <String>{};
    for (var index = 0; index < value.length; index++) {
      try {
        final item = value[index];
        if (item is! Map) throw const FormatException();
        final json = Map<String, dynamic>.from(item);
        if (json['id'] is! String ||
            json['itemName'] is! String ||
            json['total'] is! num ||
            json['verdict'] is! String ||
            json['userChoice'] is! String ||
            json['summary'] is! String ||
            json['createdAt'] is! String ||
            (json['waitUntil'] != null && json['waitUntil'] is! String) ||
            (json['events'] != null && json['events'] is! List) ||
            (json['referencedHistory'] != null &&
                json['referencedHistory'] is! List) ||
            (json['referencedPatterns'] != null &&
                json['referencedPatterns'] is! List) ||
            (json['alternatives'] != null && json['alternatives'] is! List) ||
            !_isNullableString(json['feedback']) ||
            !_isNullableString(json['usageFrequency']) ||
            (json['satisfaction'] != null && json['satisfaction'] is! int) ||
            !_isNullableString(json['regretReason']) ||
            !_isNullableString(json['category']) ||
            (json['tags'] != null && json['tags'] is! List) ||
            !_isNullableString(json['risk']) ||
            !_isNullableString(json['confidence']) ||
            !_isNullableString(json['budgetImpact'])) {
          throw const FormatException();
        }
        final events = json['events'] as List?;
        final references = json['referencedHistory'] as List?;
        final patternReferences = json['referencedPatterns'] as List?;
        final alternatives = json['alternatives'] as List?;
        final tags = json['tags'] as List?;
        if (events != null &&
                events.any(
                  (event) =>
                      event is! Map ||
                      event['status'] is! String ||
                      event['occurredAt'] is! String,
                ) ||
            references != null &&
                references.any((reference) => reference is! String) ||
            patternReferences != null &&
                patternReferences.any((reference) => reference is! String) ||
            alternatives != null &&
                alternatives.any((alternative) => alternative is! String) ||
            tags != null &&
                (tags.length > 10 ||
                    tags.any((tag) => tag is! String || tag.trim().isEmpty))) {
          throw const FormatException();
        }
        final record = DecisionRecord.fromJson(json);
        if (record.id.trim().isEmpty ||
            record.itemName.trim().isEmpty ||
            record.total < 0 ||
            !record.total.isFinite ||
            (record.satisfaction != null &&
                (record.satisfaction! < 1 || record.satisfaction! > 5))) {
          throw const FormatException();
        }
        if (!ids.add(record.id)) {
          throw DataImportException('decisions 中存在重复 ID：${record.id}');
        }
        records.add(record);
      } on DataImportException {
        rethrow;
      } on Object {
        throw DataImportException('第 ${index + 1} 条决策记录格式有误');
      }
    }
    return records;
  }

  List<ConsumptionRule> _parseRules(Object? value, int version) {
    if (value == null && version == 1) return const [];
    if (value is! List) {
      throw const DataImportException('rules 必须是数组');
    }
    final rules = <ConsumptionRule>[];
    final ids = <String>{};
    for (var index = 0; index < value.length; index++) {
      try {
        final item = value[index];
        if (item is! Map) throw const FormatException();
        final json = Map<String, dynamic>.from(item);
        if (json['id'] is! String ||
            json['name'] is! String ||
            json['description'] is! String ||
            (json['minimumAmount'] != null && json['minimumAmount'] is! num) ||
            (json['waitDays'] != null && json['waitDays'] is! num) ||
            (json['enabled'] != null && json['enabled'] is! bool)) {
          throw const FormatException();
        }
        final rule = ConsumptionRule.fromJson(json);
        if (rule.id.trim().isEmpty ||
            rule.name.trim().isEmpty ||
            rule.description.trim().isEmpty ||
            (rule.minimumAmount != null &&
                (rule.minimumAmount! < 0 || !rule.minimumAmount!.isFinite)) ||
            (rule.waitDays != null && rule.waitDays! < 0)) {
          throw const FormatException();
        }
        if (!ids.add(rule.id)) {
          throw DataImportException('rules 中存在重复 ID：${rule.id}');
        }
        rules.add(rule);
      } on DataImportException {
        rethrow;
      } on Object {
        throw DataImportException('第 ${index + 1} 条消费规则格式有误');
      }
    }
    return rules;
  }

  List<PersonalPattern> _parsePatterns(Object? value, int version) {
    if (value == null && version < 4) return const [];
    if (value is! List) {
      throw const DataImportException('personal_patterns 必须是数组');
    }
    try {
      final patterns = value
          .map(
            (item) => PersonalPattern.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      final ids = <String>{};
      if (patterns.any(
        (pattern) =>
            pattern.id.trim().isEmpty ||
            pattern.text.trim().isEmpty ||
            pattern.text.length > 200 ||
            !ids.add(pattern.id) ||
            !const {
              'candidate',
              'confirmed',
              'ignored',
            }.contains(pattern.status),
      )) {
        throw const FormatException();
      }
      return patterns;
    } on Object {
      throw const DataImportException('personal_patterns 格式有误');
    }
  }

  double? _parseBudget(Object? value) {
    if (value == null) return null;
    if (value is! num || value < 0 || !value.isFinite) {
      throw const DataImportException('monthly_budget 必须是非负数字');
    }
    return value.toDouble();
  }

  bool _isNullableString(Object? value) => value == null || value is String;

  Future<void> _insertDecision(DecisionRecord record) async {
    await _database
        .into(_database.decisions)
        .insert(
          DecisionsCompanion.insert(
            id: record.id,
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
            category: Value(record.category),
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
              decisionId: record.id,
              position: position,
              status: event.status,
              occurredAt: event.occurredAt,
            ),
          );
    }
    for (final (position, tag) in record.tags.indexed) {
      await _database
          .into(_database.decisionTags)
          .insert(
            DecisionTagsCompanion.insert(
              decisionId: record.id,
              position: position,
              tag: tag,
            ),
          );
    }
    for (final (position, summary) in record.referencedHistory.indexed) {
      await _database
          .into(_database.decisionReferences)
          .insert(
            DecisionReferencesCompanion.insert(
              decisionId: record.id,
              position: position,
              summary: summary,
            ),
          );
    }
    for (final (position, summary) in record.referencedPatterns.indexed) {
      await _database
          .into(_database.decisionPatternReferences)
          .insert(
            DecisionPatternReferencesCompanion.insert(
              decisionId: record.id,
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
              decisionId: record.id,
              position: position,
              description: description,
            ),
          );
    }
  }

  Future<void> _insertRule(ConsumptionRule rule) => _database
      .into(_database.consumptionRules)
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

  static Future<String?> _pickJsonFile() async {
    const typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
      mimeTypes: ['application/json'],
      uniformTypeIdentifiers: ['public.json'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return null;
    if (await file.length() > _maximumFileBytes) {
      throw const DataImportException('导入文件不能超过 10 MB');
    }
    return file.readAsString();
  }
}
