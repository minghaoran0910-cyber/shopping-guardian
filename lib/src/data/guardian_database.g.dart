// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guardian_database.dart';

// ignore_for_file: type=lint
class $DecisionsTable extends Decisions
    with TableInfo<$DecisionsTable, StoredDecision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userChoiceMeta = const VerificationMeta(
    'userChoice',
  );
  @override
  late final GeneratedColumn<String> userChoice = GeneratedColumn<String>(
    'user_choice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waitUntilMeta = const VerificationMeta(
    'waitUntil',
  );
  @override
  late final GeneratedColumn<DateTime> waitUntil = GeneratedColumn<DateTime>(
    'wait_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedbackMeta = const VerificationMeta(
    'feedback',
  );
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageFrequencyMeta = const VerificationMeta(
    'usageFrequency',
  );
  @override
  late final GeneratedColumn<String> usageFrequency = GeneratedColumn<String>(
    'usage_frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _satisfactionMeta = const VerificationMeta(
    'satisfaction',
  );
  @override
  late final GeneratedColumn<int> satisfaction = GeneratedColumn<int>(
    'satisfaction',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regretReasonMeta = const VerificationMeta(
    'regretReason',
  );
  @override
  late final GeneratedColumn<String> regretReason = GeneratedColumn<String>(
    'regret_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _riskMeta = const VerificationMeta('risk');
  @override
  late final GeneratedColumn<String> risk = GeneratedColumn<String>(
    'risk',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetImpactMeta = const VerificationMeta(
    'budgetImpact',
  );
  @override
  late final GeneratedColumn<String> budgetImpact = GeneratedColumn<String>(
    'budget_impact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemName,
    total,
    verdict,
    userChoice,
    summary,
    createdAt,
    waitUntil,
    feedback,
    usageFrequency,
    satisfaction,
    regretReason,
    category,
    risk,
    confidence,
    budgetImpact,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDecision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    } else if (isInserting) {
      context.missing(_verdictMeta);
    }
    if (data.containsKey('user_choice')) {
      context.handle(
        _userChoiceMeta,
        userChoice.isAcceptableOrUnknown(data['user_choice']!, _userChoiceMeta),
      );
    } else if (isInserting) {
      context.missing(_userChoiceMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('wait_until')) {
      context.handle(
        _waitUntilMeta,
        waitUntil.isAcceptableOrUnknown(data['wait_until']!, _waitUntilMeta),
      );
    }
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    }
    if (data.containsKey('usage_frequency')) {
      context.handle(
        _usageFrequencyMeta,
        usageFrequency.isAcceptableOrUnknown(
          data['usage_frequency']!,
          _usageFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('satisfaction')) {
      context.handle(
        _satisfactionMeta,
        satisfaction.isAcceptableOrUnknown(
          data['satisfaction']!,
          _satisfactionMeta,
        ),
      );
    }
    if (data.containsKey('regret_reason')) {
      context.handle(
        _regretReasonMeta,
        regretReason.isAcceptableOrUnknown(
          data['regret_reason']!,
          _regretReasonMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('risk')) {
      context.handle(
        _riskMeta,
        risk.isAcceptableOrUnknown(data['risk']!, _riskMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('budget_impact')) {
      context.handle(
        _budgetImpactMeta,
        budgetImpact.isAcceptableOrUnknown(
          data['budget_impact']!,
          _budgetImpactMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredDecision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDecision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      userChoice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_choice'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      waitUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wait_until'],
      ),
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      ),
      usageFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_frequency'],
      ),
      satisfaction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}satisfaction'],
      ),
      regretReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regret_reason'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      risk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      ),
      budgetImpact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_impact'],
      ),
    );
  }

  @override
  $DecisionsTable createAlias(String alias) {
    return $DecisionsTable(attachedDatabase, alias);
  }
}

class StoredDecision extends DataClass implements Insertable<StoredDecision> {
  final String id;
  final String itemName;
  final double total;
  final String verdict;
  final String userChoice;
  final String summary;
  final DateTime createdAt;
  final DateTime? waitUntil;
  final String? feedback;
  final String? usageFrequency;
  final int? satisfaction;
  final String? regretReason;
  final String? category;
  final String? risk;
  final String? confidence;
  final String? budgetImpact;
  const StoredDecision({
    required this.id,
    required this.itemName,
    required this.total,
    required this.verdict,
    required this.userChoice,
    required this.summary,
    required this.createdAt,
    this.waitUntil,
    this.feedback,
    this.usageFrequency,
    this.satisfaction,
    this.regretReason,
    this.category,
    this.risk,
    this.confidence,
    this.budgetImpact,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_name'] = Variable<String>(itemName);
    map['total'] = Variable<double>(total);
    map['verdict'] = Variable<String>(verdict);
    map['user_choice'] = Variable<String>(userChoice);
    map['summary'] = Variable<String>(summary);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || waitUntil != null) {
      map['wait_until'] = Variable<DateTime>(waitUntil);
    }
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(feedback);
    }
    if (!nullToAbsent || usageFrequency != null) {
      map['usage_frequency'] = Variable<String>(usageFrequency);
    }
    if (!nullToAbsent || satisfaction != null) {
      map['satisfaction'] = Variable<int>(satisfaction);
    }
    if (!nullToAbsent || regretReason != null) {
      map['regret_reason'] = Variable<String>(regretReason);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || risk != null) {
      map['risk'] = Variable<String>(risk);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<String>(confidence);
    }
    if (!nullToAbsent || budgetImpact != null) {
      map['budget_impact'] = Variable<String>(budgetImpact);
    }
    return map;
  }

  DecisionsCompanion toCompanion(bool nullToAbsent) {
    return DecisionsCompanion(
      id: Value(id),
      itemName: Value(itemName),
      total: Value(total),
      verdict: Value(verdict),
      userChoice: Value(userChoice),
      summary: Value(summary),
      createdAt: Value(createdAt),
      waitUntil: waitUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(waitUntil),
      feedback: feedback == null && nullToAbsent
          ? const Value.absent()
          : Value(feedback),
      usageFrequency: usageFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(usageFrequency),
      satisfaction: satisfaction == null && nullToAbsent
          ? const Value.absent()
          : Value(satisfaction),
      regretReason: regretReason == null && nullToAbsent
          ? const Value.absent()
          : Value(regretReason),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      risk: risk == null && nullToAbsent ? const Value.absent() : Value(risk),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      budgetImpact: budgetImpact == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetImpact),
    );
  }

  factory StoredDecision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDecision(
      id: serializer.fromJson<String>(json['id']),
      itemName: serializer.fromJson<String>(json['itemName']),
      total: serializer.fromJson<double>(json['total']),
      verdict: serializer.fromJson<String>(json['verdict']),
      userChoice: serializer.fromJson<String>(json['userChoice']),
      summary: serializer.fromJson<String>(json['summary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      waitUntil: serializer.fromJson<DateTime?>(json['waitUntil']),
      feedback: serializer.fromJson<String?>(json['feedback']),
      usageFrequency: serializer.fromJson<String?>(json['usageFrequency']),
      satisfaction: serializer.fromJson<int?>(json['satisfaction']),
      regretReason: serializer.fromJson<String?>(json['regretReason']),
      category: serializer.fromJson<String?>(json['category']),
      risk: serializer.fromJson<String?>(json['risk']),
      confidence: serializer.fromJson<String?>(json['confidence']),
      budgetImpact: serializer.fromJson<String?>(json['budgetImpact']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemName': serializer.toJson<String>(itemName),
      'total': serializer.toJson<double>(total),
      'verdict': serializer.toJson<String>(verdict),
      'userChoice': serializer.toJson<String>(userChoice),
      'summary': serializer.toJson<String>(summary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'waitUntil': serializer.toJson<DateTime?>(waitUntil),
      'feedback': serializer.toJson<String?>(feedback),
      'usageFrequency': serializer.toJson<String?>(usageFrequency),
      'satisfaction': serializer.toJson<int?>(satisfaction),
      'regretReason': serializer.toJson<String?>(regretReason),
      'category': serializer.toJson<String?>(category),
      'risk': serializer.toJson<String?>(risk),
      'confidence': serializer.toJson<String?>(confidence),
      'budgetImpact': serializer.toJson<String?>(budgetImpact),
    };
  }

  StoredDecision copyWith({
    String? id,
    String? itemName,
    double? total,
    String? verdict,
    String? userChoice,
    String? summary,
    DateTime? createdAt,
    Value<DateTime?> waitUntil = const Value.absent(),
    Value<String?> feedback = const Value.absent(),
    Value<String?> usageFrequency = const Value.absent(),
    Value<int?> satisfaction = const Value.absent(),
    Value<String?> regretReason = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> risk = const Value.absent(),
    Value<String?> confidence = const Value.absent(),
    Value<String?> budgetImpact = const Value.absent(),
  }) => StoredDecision(
    id: id ?? this.id,
    itemName: itemName ?? this.itemName,
    total: total ?? this.total,
    verdict: verdict ?? this.verdict,
    userChoice: userChoice ?? this.userChoice,
    summary: summary ?? this.summary,
    createdAt: createdAt ?? this.createdAt,
    waitUntil: waitUntil.present ? waitUntil.value : this.waitUntil,
    feedback: feedback.present ? feedback.value : this.feedback,
    usageFrequency: usageFrequency.present
        ? usageFrequency.value
        : this.usageFrequency,
    satisfaction: satisfaction.present ? satisfaction.value : this.satisfaction,
    regretReason: regretReason.present ? regretReason.value : this.regretReason,
    category: category.present ? category.value : this.category,
    risk: risk.present ? risk.value : this.risk,
    confidence: confidence.present ? confidence.value : this.confidence,
    budgetImpact: budgetImpact.present ? budgetImpact.value : this.budgetImpact,
  );
  StoredDecision copyWithCompanion(DecisionsCompanion data) {
    return StoredDecision(
      id: data.id.present ? data.id.value : this.id,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      total: data.total.present ? data.total.value : this.total,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      userChoice: data.userChoice.present
          ? data.userChoice.value
          : this.userChoice,
      summary: data.summary.present ? data.summary.value : this.summary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      waitUntil: data.waitUntil.present ? data.waitUntil.value : this.waitUntil,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      usageFrequency: data.usageFrequency.present
          ? data.usageFrequency.value
          : this.usageFrequency,
      satisfaction: data.satisfaction.present
          ? data.satisfaction.value
          : this.satisfaction,
      regretReason: data.regretReason.present
          ? data.regretReason.value
          : this.regretReason,
      category: data.category.present ? data.category.value : this.category,
      risk: data.risk.present ? data.risk.value : this.risk,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      budgetImpact: data.budgetImpact.present
          ? data.budgetImpact.value
          : this.budgetImpact,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDecision(')
          ..write('id: $id, ')
          ..write('itemName: $itemName, ')
          ..write('total: $total, ')
          ..write('verdict: $verdict, ')
          ..write('userChoice: $userChoice, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('waitUntil: $waitUntil, ')
          ..write('feedback: $feedback, ')
          ..write('usageFrequency: $usageFrequency, ')
          ..write('satisfaction: $satisfaction, ')
          ..write('regretReason: $regretReason, ')
          ..write('category: $category, ')
          ..write('risk: $risk, ')
          ..write('confidence: $confidence, ')
          ..write('budgetImpact: $budgetImpact')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemName,
    total,
    verdict,
    userChoice,
    summary,
    createdAt,
    waitUntil,
    feedback,
    usageFrequency,
    satisfaction,
    regretReason,
    category,
    risk,
    confidence,
    budgetImpact,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDecision &&
          other.id == this.id &&
          other.itemName == this.itemName &&
          other.total == this.total &&
          other.verdict == this.verdict &&
          other.userChoice == this.userChoice &&
          other.summary == this.summary &&
          other.createdAt == this.createdAt &&
          other.waitUntil == this.waitUntil &&
          other.feedback == this.feedback &&
          other.usageFrequency == this.usageFrequency &&
          other.satisfaction == this.satisfaction &&
          other.regretReason == this.regretReason &&
          other.category == this.category &&
          other.risk == this.risk &&
          other.confidence == this.confidence &&
          other.budgetImpact == this.budgetImpact);
}

class DecisionsCompanion extends UpdateCompanion<StoredDecision> {
  final Value<String> id;
  final Value<String> itemName;
  final Value<double> total;
  final Value<String> verdict;
  final Value<String> userChoice;
  final Value<String> summary;
  final Value<DateTime> createdAt;
  final Value<DateTime?> waitUntil;
  final Value<String?> feedback;
  final Value<String?> usageFrequency;
  final Value<int?> satisfaction;
  final Value<String?> regretReason;
  final Value<String?> category;
  final Value<String?> risk;
  final Value<String?> confidence;
  final Value<String?> budgetImpact;
  final Value<int> rowid;
  const DecisionsCompanion({
    this.id = const Value.absent(),
    this.itemName = const Value.absent(),
    this.total = const Value.absent(),
    this.verdict = const Value.absent(),
    this.userChoice = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.waitUntil = const Value.absent(),
    this.feedback = const Value.absent(),
    this.usageFrequency = const Value.absent(),
    this.satisfaction = const Value.absent(),
    this.regretReason = const Value.absent(),
    this.category = const Value.absent(),
    this.risk = const Value.absent(),
    this.confidence = const Value.absent(),
    this.budgetImpact = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionsCompanion.insert({
    required String id,
    required String itemName,
    required double total,
    required String verdict,
    required String userChoice,
    required String summary,
    required DateTime createdAt,
    this.waitUntil = const Value.absent(),
    this.feedback = const Value.absent(),
    this.usageFrequency = const Value.absent(),
    this.satisfaction = const Value.absent(),
    this.regretReason = const Value.absent(),
    this.category = const Value.absent(),
    this.risk = const Value.absent(),
    this.confidence = const Value.absent(),
    this.budgetImpact = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemName = Value(itemName),
       total = Value(total),
       verdict = Value(verdict),
       userChoice = Value(userChoice),
       summary = Value(summary),
       createdAt = Value(createdAt);
  static Insertable<StoredDecision> custom({
    Expression<String>? id,
    Expression<String>? itemName,
    Expression<double>? total,
    Expression<String>? verdict,
    Expression<String>? userChoice,
    Expression<String>? summary,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? waitUntil,
    Expression<String>? feedback,
    Expression<String>? usageFrequency,
    Expression<int>? satisfaction,
    Expression<String>? regretReason,
    Expression<String>? category,
    Expression<String>? risk,
    Expression<String>? confidence,
    Expression<String>? budgetImpact,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemName != null) 'item_name': itemName,
      if (total != null) 'total': total,
      if (verdict != null) 'verdict': verdict,
      if (userChoice != null) 'user_choice': userChoice,
      if (summary != null) 'summary': summary,
      if (createdAt != null) 'created_at': createdAt,
      if (waitUntil != null) 'wait_until': waitUntil,
      if (feedback != null) 'feedback': feedback,
      if (usageFrequency != null) 'usage_frequency': usageFrequency,
      if (satisfaction != null) 'satisfaction': satisfaction,
      if (regretReason != null) 'regret_reason': regretReason,
      if (category != null) 'category': category,
      if (risk != null) 'risk': risk,
      if (confidence != null) 'confidence': confidence,
      if (budgetImpact != null) 'budget_impact': budgetImpact,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemName,
    Value<double>? total,
    Value<String>? verdict,
    Value<String>? userChoice,
    Value<String>? summary,
    Value<DateTime>? createdAt,
    Value<DateTime?>? waitUntil,
    Value<String?>? feedback,
    Value<String?>? usageFrequency,
    Value<int?>? satisfaction,
    Value<String?>? regretReason,
    Value<String?>? category,
    Value<String?>? risk,
    Value<String?>? confidence,
    Value<String?>? budgetImpact,
    Value<int>? rowid,
  }) {
    return DecisionsCompanion(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      total: total ?? this.total,
      verdict: verdict ?? this.verdict,
      userChoice: userChoice ?? this.userChoice,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      waitUntil: waitUntil ?? this.waitUntil,
      feedback: feedback ?? this.feedback,
      usageFrequency: usageFrequency ?? this.usageFrequency,
      satisfaction: satisfaction ?? this.satisfaction,
      regretReason: regretReason ?? this.regretReason,
      category: category ?? this.category,
      risk: risk ?? this.risk,
      confidence: confidence ?? this.confidence,
      budgetImpact: budgetImpact ?? this.budgetImpact,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (userChoice.present) {
      map['user_choice'] = Variable<String>(userChoice.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (waitUntil.present) {
      map['wait_until'] = Variable<DateTime>(waitUntil.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (usageFrequency.present) {
      map['usage_frequency'] = Variable<String>(usageFrequency.value);
    }
    if (satisfaction.present) {
      map['satisfaction'] = Variable<int>(satisfaction.value);
    }
    if (regretReason.present) {
      map['regret_reason'] = Variable<String>(regretReason.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (risk.present) {
      map['risk'] = Variable<String>(risk.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (budgetImpact.present) {
      map['budget_impact'] = Variable<String>(budgetImpact.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionsCompanion(')
          ..write('id: $id, ')
          ..write('itemName: $itemName, ')
          ..write('total: $total, ')
          ..write('verdict: $verdict, ')
          ..write('userChoice: $userChoice, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('waitUntil: $waitUntil, ')
          ..write('feedback: $feedback, ')
          ..write('usageFrequency: $usageFrequency, ')
          ..write('satisfaction: $satisfaction, ')
          ..write('regretReason: $regretReason, ')
          ..write('category: $category, ')
          ..write('risk: $risk, ')
          ..write('confidence: $confidence, ')
          ..write('budgetImpact: $budgetImpact, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecisionEventsTable extends DecisionEvents
    with TableInfo<$DecisionEventsTable, StoredDecisionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    decisionId,
    position,
    status,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decision_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDecisionEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {decisionId, position};
  @override
  StoredDecisionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDecisionEvent(
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $DecisionEventsTable createAlias(String alias) {
    return $DecisionEventsTable(attachedDatabase, alias);
  }
}

class StoredDecisionEvent extends DataClass
    implements Insertable<StoredDecisionEvent> {
  final String decisionId;
  final int position;
  final String status;
  final DateTime occurredAt;
  const StoredDecisionEvent({
    required this.decisionId,
    required this.position,
    required this.status,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['decision_id'] = Variable<String>(decisionId);
    map['position'] = Variable<int>(position);
    map['status'] = Variable<String>(status);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  DecisionEventsCompanion toCompanion(bool nullToAbsent) {
    return DecisionEventsCompanion(
      decisionId: Value(decisionId),
      position: Value(position),
      status: Value(status),
      occurredAt: Value(occurredAt),
    );
  }

  factory StoredDecisionEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDecisionEvent(
      decisionId: serializer.fromJson<String>(json['decisionId']),
      position: serializer.fromJson<int>(json['position']),
      status: serializer.fromJson<String>(json['status']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'decisionId': serializer.toJson<String>(decisionId),
      'position': serializer.toJson<int>(position),
      'status': serializer.toJson<String>(status),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  StoredDecisionEvent copyWith({
    String? decisionId,
    int? position,
    String? status,
    DateTime? occurredAt,
  }) => StoredDecisionEvent(
    decisionId: decisionId ?? this.decisionId,
    position: position ?? this.position,
    status: status ?? this.status,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  StoredDecisionEvent copyWithCompanion(DecisionEventsCompanion data) {
    return StoredDecisionEvent(
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
      position: data.position.present ? data.position.value : this.position,
      status: data.status.present ? data.status.value : this.status,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDecisionEvent(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(decisionId, position, status, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDecisionEvent &&
          other.decisionId == this.decisionId &&
          other.position == this.position &&
          other.status == this.status &&
          other.occurredAt == this.occurredAt);
}

class DecisionEventsCompanion extends UpdateCompanion<StoredDecisionEvent> {
  final Value<String> decisionId;
  final Value<int> position;
  final Value<String> status;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const DecisionEventsCompanion({
    this.decisionId = const Value.absent(),
    this.position = const Value.absent(),
    this.status = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionEventsCompanion.insert({
    required String decisionId,
    required int position,
    required String status,
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : decisionId = Value(decisionId),
       position = Value(position),
       status = Value(status),
       occurredAt = Value(occurredAt);
  static Insertable<StoredDecisionEvent> custom({
    Expression<String>? decisionId,
    Expression<int>? position,
    Expression<String>? status,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (decisionId != null) 'decision_id': decisionId,
      if (position != null) 'position': position,
      if (status != null) 'status': status,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionEventsCompanion copyWith({
    Value<String>? decisionId,
    Value<int>? position,
    Value<String>? status,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return DecisionEventsCompanion(
      decisionId: decisionId ?? this.decisionId,
      position: position ?? this.position,
      status: status ?? this.status,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionEventsCompanion(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('status: $status, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecisionReferencesTable extends DecisionReferences
    with TableInfo<$DecisionReferencesTable, StoredDecisionReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [decisionId, position, summary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decision_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDecisionReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {decisionId, position};
  @override
  StoredDecisionReference map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDecisionReference(
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
    );
  }

  @override
  $DecisionReferencesTable createAlias(String alias) {
    return $DecisionReferencesTable(attachedDatabase, alias);
  }
}

class StoredDecisionReference extends DataClass
    implements Insertable<StoredDecisionReference> {
  final String decisionId;
  final int position;
  final String summary;
  const StoredDecisionReference({
    required this.decisionId,
    required this.position,
    required this.summary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['decision_id'] = Variable<String>(decisionId);
    map['position'] = Variable<int>(position);
    map['summary'] = Variable<String>(summary);
    return map;
  }

  DecisionReferencesCompanion toCompanion(bool nullToAbsent) {
    return DecisionReferencesCompanion(
      decisionId: Value(decisionId),
      position: Value(position),
      summary: Value(summary),
    );
  }

  factory StoredDecisionReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDecisionReference(
      decisionId: serializer.fromJson<String>(json['decisionId']),
      position: serializer.fromJson<int>(json['position']),
      summary: serializer.fromJson<String>(json['summary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'decisionId': serializer.toJson<String>(decisionId),
      'position': serializer.toJson<int>(position),
      'summary': serializer.toJson<String>(summary),
    };
  }

  StoredDecisionReference copyWith({
    String? decisionId,
    int? position,
    String? summary,
  }) => StoredDecisionReference(
    decisionId: decisionId ?? this.decisionId,
    position: position ?? this.position,
    summary: summary ?? this.summary,
  );
  StoredDecisionReference copyWithCompanion(DecisionReferencesCompanion data) {
    return StoredDecisionReference(
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
      position: data.position.present ? data.position.value : this.position,
      summary: data.summary.present ? data.summary.value : this.summary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDecisionReference(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('summary: $summary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(decisionId, position, summary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDecisionReference &&
          other.decisionId == this.decisionId &&
          other.position == this.position &&
          other.summary == this.summary);
}

class DecisionReferencesCompanion
    extends UpdateCompanion<StoredDecisionReference> {
  final Value<String> decisionId;
  final Value<int> position;
  final Value<String> summary;
  final Value<int> rowid;
  const DecisionReferencesCompanion({
    this.decisionId = const Value.absent(),
    this.position = const Value.absent(),
    this.summary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionReferencesCompanion.insert({
    required String decisionId,
    required int position,
    required String summary,
    this.rowid = const Value.absent(),
  }) : decisionId = Value(decisionId),
       position = Value(position),
       summary = Value(summary);
  static Insertable<StoredDecisionReference> custom({
    Expression<String>? decisionId,
    Expression<int>? position,
    Expression<String>? summary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (decisionId != null) 'decision_id': decisionId,
      if (position != null) 'position': position,
      if (summary != null) 'summary': summary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionReferencesCompanion copyWith({
    Value<String>? decisionId,
    Value<int>? position,
    Value<String>? summary,
    Value<int>? rowid,
  }) {
    return DecisionReferencesCompanion(
      decisionId: decisionId ?? this.decisionId,
      position: position ?? this.position,
      summary: summary ?? this.summary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionReferencesCompanion(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('summary: $summary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecisionAlternativesTable extends DecisionAlternatives
    with TableInfo<$DecisionAlternativesTable, StoredDecisionAlternative> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionAlternativesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [decisionId, position, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decision_alternatives';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDecisionAlternative> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {decisionId, position};
  @override
  StoredDecisionAlternative map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDecisionAlternative(
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $DecisionAlternativesTable createAlias(String alias) {
    return $DecisionAlternativesTable(attachedDatabase, alias);
  }
}

class StoredDecisionAlternative extends DataClass
    implements Insertable<StoredDecisionAlternative> {
  final String decisionId;
  final int position;
  final String description;
  const StoredDecisionAlternative({
    required this.decisionId,
    required this.position,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['decision_id'] = Variable<String>(decisionId);
    map['position'] = Variable<int>(position);
    map['description'] = Variable<String>(description);
    return map;
  }

  DecisionAlternativesCompanion toCompanion(bool nullToAbsent) {
    return DecisionAlternativesCompanion(
      decisionId: Value(decisionId),
      position: Value(position),
      description: Value(description),
    );
  }

  factory StoredDecisionAlternative.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDecisionAlternative(
      decisionId: serializer.fromJson<String>(json['decisionId']),
      position: serializer.fromJson<int>(json['position']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'decisionId': serializer.toJson<String>(decisionId),
      'position': serializer.toJson<int>(position),
      'description': serializer.toJson<String>(description),
    };
  }

  StoredDecisionAlternative copyWith({
    String? decisionId,
    int? position,
    String? description,
  }) => StoredDecisionAlternative(
    decisionId: decisionId ?? this.decisionId,
    position: position ?? this.position,
    description: description ?? this.description,
  );
  StoredDecisionAlternative copyWithCompanion(
    DecisionAlternativesCompanion data,
  ) {
    return StoredDecisionAlternative(
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
      position: data.position.present ? data.position.value : this.position,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDecisionAlternative(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(decisionId, position, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDecisionAlternative &&
          other.decisionId == this.decisionId &&
          other.position == this.position &&
          other.description == this.description);
}

class DecisionAlternativesCompanion
    extends UpdateCompanion<StoredDecisionAlternative> {
  final Value<String> decisionId;
  final Value<int> position;
  final Value<String> description;
  final Value<int> rowid;
  const DecisionAlternativesCompanion({
    this.decisionId = const Value.absent(),
    this.position = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionAlternativesCompanion.insert({
    required String decisionId,
    required int position,
    required String description,
    this.rowid = const Value.absent(),
  }) : decisionId = Value(decisionId),
       position = Value(position),
       description = Value(description);
  static Insertable<StoredDecisionAlternative> custom({
    Expression<String>? decisionId,
    Expression<int>? position,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (decisionId != null) 'decision_id': decisionId,
      if (position != null) 'position': position,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionAlternativesCompanion copyWith({
    Value<String>? decisionId,
    Value<int>? position,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return DecisionAlternativesCompanion(
      decisionId: decisionId ?? this.decisionId,
      position: position ?? this.position,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionAlternativesCompanion(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecisionTagsTable extends DecisionTags
    with TableInfo<$DecisionTagsTable, StoredDecisionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [decisionId, position, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decision_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDecisionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {decisionId, position};
  @override
  StoredDecisionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDecisionTag(
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $DecisionTagsTable createAlias(String alias) {
    return $DecisionTagsTable(attachedDatabase, alias);
  }
}

class StoredDecisionTag extends DataClass
    implements Insertable<StoredDecisionTag> {
  final String decisionId;
  final int position;
  final String tag;
  const StoredDecisionTag({
    required this.decisionId,
    required this.position,
    required this.tag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['decision_id'] = Variable<String>(decisionId);
    map['position'] = Variable<int>(position);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  DecisionTagsCompanion toCompanion(bool nullToAbsent) {
    return DecisionTagsCompanion(
      decisionId: Value(decisionId),
      position: Value(position),
      tag: Value(tag),
    );
  }

  factory StoredDecisionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDecisionTag(
      decisionId: serializer.fromJson<String>(json['decisionId']),
      position: serializer.fromJson<int>(json['position']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'decisionId': serializer.toJson<String>(decisionId),
      'position': serializer.toJson<int>(position),
      'tag': serializer.toJson<String>(tag),
    };
  }

  StoredDecisionTag copyWith({
    String? decisionId,
    int? position,
    String? tag,
  }) => StoredDecisionTag(
    decisionId: decisionId ?? this.decisionId,
    position: position ?? this.position,
    tag: tag ?? this.tag,
  );
  StoredDecisionTag copyWithCompanion(DecisionTagsCompanion data) {
    return StoredDecisionTag(
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
      position: data.position.present ? data.position.value : this.position,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDecisionTag(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(decisionId, position, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDecisionTag &&
          other.decisionId == this.decisionId &&
          other.position == this.position &&
          other.tag == this.tag);
}

class DecisionTagsCompanion extends UpdateCompanion<StoredDecisionTag> {
  final Value<String> decisionId;
  final Value<int> position;
  final Value<String> tag;
  final Value<int> rowid;
  const DecisionTagsCompanion({
    this.decisionId = const Value.absent(),
    this.position = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionTagsCompanion.insert({
    required String decisionId,
    required int position,
    required String tag,
    this.rowid = const Value.absent(),
  }) : decisionId = Value(decisionId),
       position = Value(position),
       tag = Value(tag);
  static Insertable<StoredDecisionTag> custom({
    Expression<String>? decisionId,
    Expression<int>? position,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (decisionId != null) 'decision_id': decisionId,
      if (position != null) 'position': position,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionTagsCompanion copyWith({
    Value<String>? decisionId,
    Value<int>? position,
    Value<String>? tag,
    Value<int>? rowid,
  }) {
    return DecisionTagsCompanion(
      decisionId: decisionId ?? this.decisionId,
      position: position ?? this.position,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionTagsCompanion(')
          ..write('decisionId: $decisionId, ')
          ..write('position: $position, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsumptionRulesTable extends ConsumptionRules
    with TableInfo<$ConsumptionRulesTable, StoredConsumptionRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsumptionRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumAmountMeta = const VerificationMeta(
    'minimumAmount',
  );
  @override
  late final GeneratedColumn<double> minimumAmount = GeneratedColumn<double>(
    'minimum_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waitDaysMeta = const VerificationMeta(
    'waitDays',
  );
  @override
  late final GeneratedColumn<int> waitDays = GeneratedColumn<int>(
    'wait_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    minimumAmount,
    waitDays,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consumption_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredConsumptionRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('minimum_amount')) {
      context.handle(
        _minimumAmountMeta,
        minimumAmount.isAcceptableOrUnknown(
          data['minimum_amount']!,
          _minimumAmountMeta,
        ),
      );
    }
    if (data.containsKey('wait_days')) {
      context.handle(
        _waitDaysMeta,
        waitDays.isAcceptableOrUnknown(data['wait_days']!, _waitDaysMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredConsumptionRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredConsumptionRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      minimumAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_amount'],
      ),
      waitDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wait_days'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ConsumptionRulesTable createAlias(String alias) {
    return $ConsumptionRulesTable(attachedDatabase, alias);
  }
}

class StoredConsumptionRule extends DataClass
    implements Insertable<StoredConsumptionRule> {
  final String id;
  final String name;
  final String description;
  final double? minimumAmount;
  final int? waitDays;
  final bool enabled;
  const StoredConsumptionRule({
    required this.id,
    required this.name,
    required this.description,
    this.minimumAmount,
    this.waitDays,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || minimumAmount != null) {
      map['minimum_amount'] = Variable<double>(minimumAmount);
    }
    if (!nullToAbsent || waitDays != null) {
      map['wait_days'] = Variable<int>(waitDays);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ConsumptionRulesCompanion toCompanion(bool nullToAbsent) {
    return ConsumptionRulesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      minimumAmount: minimumAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumAmount),
      waitDays: waitDays == null && nullToAbsent
          ? const Value.absent()
          : Value(waitDays),
      enabled: Value(enabled),
    );
  }

  factory StoredConsumptionRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredConsumptionRule(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      minimumAmount: serializer.fromJson<double?>(json['minimumAmount']),
      waitDays: serializer.fromJson<int?>(json['waitDays']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'minimumAmount': serializer.toJson<double?>(minimumAmount),
      'waitDays': serializer.toJson<int?>(waitDays),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  StoredConsumptionRule copyWith({
    String? id,
    String? name,
    String? description,
    Value<double?> minimumAmount = const Value.absent(),
    Value<int?> waitDays = const Value.absent(),
    bool? enabled,
  }) => StoredConsumptionRule(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    minimumAmount: minimumAmount.present
        ? minimumAmount.value
        : this.minimumAmount,
    waitDays: waitDays.present ? waitDays.value : this.waitDays,
    enabled: enabled ?? this.enabled,
  );
  StoredConsumptionRule copyWithCompanion(ConsumptionRulesCompanion data) {
    return StoredConsumptionRule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      minimumAmount: data.minimumAmount.present
          ? data.minimumAmount.value
          : this.minimumAmount,
      waitDays: data.waitDays.present ? data.waitDays.value : this.waitDays,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredConsumptionRule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('minimumAmount: $minimumAmount, ')
          ..write('waitDays: $waitDays, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, minimumAmount, waitDays, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredConsumptionRule &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.minimumAmount == this.minimumAmount &&
          other.waitDays == this.waitDays &&
          other.enabled == this.enabled);
}

class ConsumptionRulesCompanion extends UpdateCompanion<StoredConsumptionRule> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<double?> minimumAmount;
  final Value<int?> waitDays;
  final Value<bool> enabled;
  final Value<int> rowid;
  const ConsumptionRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.minimumAmount = const Value.absent(),
    this.waitDays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsumptionRulesCompanion.insert({
    required String id,
    required String name,
    required String description,
    this.minimumAmount = const Value.absent(),
    this.waitDays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description);
  static Insertable<StoredConsumptionRule> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? minimumAmount,
    Expression<int>? waitDays,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (minimumAmount != null) 'minimum_amount': minimumAmount,
      if (waitDays != null) 'wait_days': waitDays,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsumptionRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<double?>? minimumAmount,
    Value<int?>? waitDays,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return ConsumptionRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      waitDays: waitDays ?? this.waitDays,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (minimumAmount.present) {
      map['minimum_amount'] = Variable<double>(minimumAmount.value);
    }
    if (waitDays.present) {
      map['wait_days'] = Variable<int>(waitDays.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsumptionRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('minimumAmount: $minimumAmount, ')
          ..write('waitDays: $waitDays, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppValuesTable extends AppValues
    with TableInfo<$AppValuesTable, AppValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppValue(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppValuesTable createAlias(String alias) {
    return $AppValuesTable(attachedDatabase, alias);
  }
}

class AppValue extends DataClass implements Insertable<AppValue> {
  final String key;
  final String value;
  const AppValue({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppValuesCompanion toCompanion(bool nullToAbsent) {
    return AppValuesCompanion(key: Value(key), value: Value(value));
  }

  factory AppValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppValue(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppValue copyWith({String? key, String? value}) =>
      AppValue(key: key ?? this.key, value: value ?? this.value);
  AppValue copyWithCompanion(AppValuesCompanion data) {
    return AppValue(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppValue(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppValue && other.key == this.key && other.value == this.value);
}

class AppValuesCompanion extends UpdateCompanion<AppValue> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppValue> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppValuesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MigrationQuarantineTable extends MigrationQuarantine
    with TableInfo<$MigrationQuarantineTable, MigrationQuarantineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MigrationQuarantineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawValueMeta = const VerificationMeta(
    'rawValue',
  );
  @override
  late final GeneratedColumn<String> rawValue = GeneratedColumn<String>(
    'raw_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quarantinedAtMeta = const VerificationMeta(
    'quarantinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> quarantinedAt =
      GeneratedColumn<DateTime>(
        'quarantined_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceKey,
    rawValue,
    error,
    quarantinedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migration_quarantine';
  @override
  VerificationContext validateIntegrity(
    Insertable<MigrationQuarantineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('raw_value')) {
      context.handle(
        _rawValueMeta,
        rawValue.isAcceptableOrUnknown(data['raw_value']!, _rawValueMeta),
      );
    } else if (isInserting) {
      context.missing(_rawValueMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    } else if (isInserting) {
      context.missing(_errorMeta);
    }
    if (data.containsKey('quarantined_at')) {
      context.handle(
        _quarantinedAtMeta,
        quarantinedAt.isAcceptableOrUnknown(
          data['quarantined_at']!,
          _quarantinedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quarantinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MigrationQuarantineData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MigrationQuarantineData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      rawValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_value'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      )!,
      quarantinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}quarantined_at'],
      )!,
    );
  }

  @override
  $MigrationQuarantineTable createAlias(String alias) {
    return $MigrationQuarantineTable(attachedDatabase, alias);
  }
}

class MigrationQuarantineData extends DataClass
    implements Insertable<MigrationQuarantineData> {
  final int id;
  final String sourceKey;
  final String rawValue;
  final String error;
  final DateTime quarantinedAt;
  const MigrationQuarantineData({
    required this.id,
    required this.sourceKey,
    required this.rawValue,
    required this.error,
    required this.quarantinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_key'] = Variable<String>(sourceKey);
    map['raw_value'] = Variable<String>(rawValue);
    map['error'] = Variable<String>(error);
    map['quarantined_at'] = Variable<DateTime>(quarantinedAt);
    return map;
  }

  MigrationQuarantineCompanion toCompanion(bool nullToAbsent) {
    return MigrationQuarantineCompanion(
      id: Value(id),
      sourceKey: Value(sourceKey),
      rawValue: Value(rawValue),
      error: Value(error),
      quarantinedAt: Value(quarantinedAt),
    );
  }

  factory MigrationQuarantineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MigrationQuarantineData(
      id: serializer.fromJson<int>(json['id']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      rawValue: serializer.fromJson<String>(json['rawValue']),
      error: serializer.fromJson<String>(json['error']),
      quarantinedAt: serializer.fromJson<DateTime>(json['quarantinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'rawValue': serializer.toJson<String>(rawValue),
      'error': serializer.toJson<String>(error),
      'quarantinedAt': serializer.toJson<DateTime>(quarantinedAt),
    };
  }

  MigrationQuarantineData copyWith({
    int? id,
    String? sourceKey,
    String? rawValue,
    String? error,
    DateTime? quarantinedAt,
  }) => MigrationQuarantineData(
    id: id ?? this.id,
    sourceKey: sourceKey ?? this.sourceKey,
    rawValue: rawValue ?? this.rawValue,
    error: error ?? this.error,
    quarantinedAt: quarantinedAt ?? this.quarantinedAt,
  );
  MigrationQuarantineData copyWithCompanion(MigrationQuarantineCompanion data) {
    return MigrationQuarantineData(
      id: data.id.present ? data.id.value : this.id,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      rawValue: data.rawValue.present ? data.rawValue.value : this.rawValue,
      error: data.error.present ? data.error.value : this.error,
      quarantinedAt: data.quarantinedAt.present
          ? data.quarantinedAt.value
          : this.quarantinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MigrationQuarantineData(')
          ..write('id: $id, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('rawValue: $rawValue, ')
          ..write('error: $error, ')
          ..write('quarantinedAt: $quarantinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceKey, rawValue, error, quarantinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MigrationQuarantineData &&
          other.id == this.id &&
          other.sourceKey == this.sourceKey &&
          other.rawValue == this.rawValue &&
          other.error == this.error &&
          other.quarantinedAt == this.quarantinedAt);
}

class MigrationQuarantineCompanion
    extends UpdateCompanion<MigrationQuarantineData> {
  final Value<int> id;
  final Value<String> sourceKey;
  final Value<String> rawValue;
  final Value<String> error;
  final Value<DateTime> quarantinedAt;
  const MigrationQuarantineCompanion({
    this.id = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.rawValue = const Value.absent(),
    this.error = const Value.absent(),
    this.quarantinedAt = const Value.absent(),
  });
  MigrationQuarantineCompanion.insert({
    this.id = const Value.absent(),
    required String sourceKey,
    required String rawValue,
    required String error,
    required DateTime quarantinedAt,
  }) : sourceKey = Value(sourceKey),
       rawValue = Value(rawValue),
       error = Value(error),
       quarantinedAt = Value(quarantinedAt);
  static Insertable<MigrationQuarantineData> custom({
    Expression<int>? id,
    Expression<String>? sourceKey,
    Expression<String>? rawValue,
    Expression<String>? error,
    Expression<DateTime>? quarantinedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceKey != null) 'source_key': sourceKey,
      if (rawValue != null) 'raw_value': rawValue,
      if (error != null) 'error': error,
      if (quarantinedAt != null) 'quarantined_at': quarantinedAt,
    });
  }

  MigrationQuarantineCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceKey,
    Value<String>? rawValue,
    Value<String>? error,
    Value<DateTime>? quarantinedAt,
  }) {
    return MigrationQuarantineCompanion(
      id: id ?? this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      rawValue: rawValue ?? this.rawValue,
      error: error ?? this.error,
      quarantinedAt: quarantinedAt ?? this.quarantinedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (rawValue.present) {
      map['raw_value'] = Variable<String>(rawValue.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (quarantinedAt.present) {
      map['quarantined_at'] = Variable<DateTime>(quarantinedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationQuarantineCompanion(')
          ..write('id: $id, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('rawValue: $rawValue, ')
          ..write('error: $error, ')
          ..write('quarantinedAt: $quarantinedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$GuardianDatabase extends GeneratedDatabase {
  _$GuardianDatabase(QueryExecutor e) : super(e);
  $GuardianDatabaseManager get managers => $GuardianDatabaseManager(this);
  late final $DecisionsTable decisions = $DecisionsTable(this);
  late final $DecisionEventsTable decisionEvents = $DecisionEventsTable(this);
  late final $DecisionReferencesTable decisionReferences =
      $DecisionReferencesTable(this);
  late final $DecisionAlternativesTable decisionAlternatives =
      $DecisionAlternativesTable(this);
  late final $DecisionTagsTable decisionTags = $DecisionTagsTable(this);
  late final $ConsumptionRulesTable consumptionRules = $ConsumptionRulesTable(
    this,
  );
  late final $AppValuesTable appValues = $AppValuesTable(this);
  late final $MigrationQuarantineTable migrationQuarantine =
      $MigrationQuarantineTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    decisions,
    decisionEvents,
    decisionReferences,
    decisionAlternatives,
    decisionTags,
    consumptionRules,
    appValues,
    migrationQuarantine,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('decision_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('decision_references', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('decision_alternatives', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('decision_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DecisionsTableCreateCompanionBuilder =
    DecisionsCompanion Function({
      required String id,
      required String itemName,
      required double total,
      required String verdict,
      required String userChoice,
      required String summary,
      required DateTime createdAt,
      Value<DateTime?> waitUntil,
      Value<String?> feedback,
      Value<String?> usageFrequency,
      Value<int?> satisfaction,
      Value<String?> regretReason,
      Value<String?> category,
      Value<String?> risk,
      Value<String?> confidence,
      Value<String?> budgetImpact,
      Value<int> rowid,
    });
typedef $$DecisionsTableUpdateCompanionBuilder =
    DecisionsCompanion Function({
      Value<String> id,
      Value<String> itemName,
      Value<double> total,
      Value<String> verdict,
      Value<String> userChoice,
      Value<String> summary,
      Value<DateTime> createdAt,
      Value<DateTime?> waitUntil,
      Value<String?> feedback,
      Value<String?> usageFrequency,
      Value<int?> satisfaction,
      Value<String?> regretReason,
      Value<String?> category,
      Value<String?> risk,
      Value<String?> confidence,
      Value<String?> budgetImpact,
      Value<int> rowid,
    });

final class $$DecisionsTableReferences
    extends
        BaseReferences<_$GuardianDatabase, $DecisionsTable, StoredDecision> {
  $$DecisionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DecisionEventsTable, List<StoredDecisionEvent>>
  _decisionEventsRefsTable(_$GuardianDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.decisionEvents,
        aliasName: 'decisions__id__decision_events__decision_id',
      );

  $$DecisionEventsTableProcessedTableManager get decisionEventsRefs {
    final manager = $$DecisionEventsTableTableManager(
      $_db,
      $_db.decisionEvents,
    ).filter((f) => f.decisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_decisionEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DecisionReferencesTable,
    List<StoredDecisionReference>
  >
  _decisionReferencesRefsTable(_$GuardianDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.decisionReferences,
        aliasName: 'decisions__id__decision_references__decision_id',
      );

  $$DecisionReferencesTableProcessedTableManager get decisionReferencesRefs {
    final manager = $$DecisionReferencesTableTableManager(
      $_db,
      $_db.decisionReferences,
    ).filter((f) => f.decisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _decisionReferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DecisionAlternativesTable,
    List<StoredDecisionAlternative>
  >
  _decisionAlternativesRefsTable(_$GuardianDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.decisionAlternatives,
        aliasName: 'decisions__id__decision_alternatives__decision_id',
      );

  $$DecisionAlternativesTableProcessedTableManager
  get decisionAlternativesRefs {
    final manager = $$DecisionAlternativesTableTableManager(
      $_db,
      $_db.decisionAlternatives,
    ).filter((f) => f.decisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _decisionAlternativesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DecisionTagsTable, List<StoredDecisionTag>>
  _decisionTagsRefsTable(_$GuardianDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.decisionTags,
        aliasName: 'decisions__id__decision_tags__decision_id',
      );

  $$DecisionTagsTableProcessedTableManager get decisionTagsRefs {
    final manager = $$DecisionTagsTableTableManager(
      $_db,
      $_db.decisionTags,
    ).filter((f) => f.decisionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_decisionTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecisionsTableFilterComposer
    extends Composer<_$GuardianDatabase, $DecisionsTable> {
  $$DecisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userChoice => $composableBuilder(
    column: $table.userChoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get waitUntil => $composableBuilder(
    column: $table.waitUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get satisfaction => $composableBuilder(
    column: $table.satisfaction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regretReason => $composableBuilder(
    column: $table.regretReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get risk => $composableBuilder(
    column: $table.risk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetImpact => $composableBuilder(
    column: $table.budgetImpact,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> decisionEventsRefs(
    Expression<bool> Function($$DecisionEventsTableFilterComposer f) f,
  ) {
    final $$DecisionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionEvents,
      getReferencedColumn: (t) => t.decisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionEventsTableFilterComposer(
            $db: $db,
            $table: $db.decisionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> decisionReferencesRefs(
    Expression<bool> Function($$DecisionReferencesTableFilterComposer f) f,
  ) {
    final $$DecisionReferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionReferences,
      getReferencedColumn: (t) => t.decisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionReferencesTableFilterComposer(
            $db: $db,
            $table: $db.decisionReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> decisionAlternativesRefs(
    Expression<bool> Function($$DecisionAlternativesTableFilterComposer f) f,
  ) {
    final $$DecisionAlternativesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionAlternatives,
      getReferencedColumn: (t) => t.decisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionAlternativesTableFilterComposer(
            $db: $db,
            $table: $db.decisionAlternatives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> decisionTagsRefs(
    Expression<bool> Function($$DecisionTagsTableFilterComposer f) f,
  ) {
    final $$DecisionTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionTags,
      getReferencedColumn: (t) => t.decisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionTagsTableFilterComposer(
            $db: $db,
            $table: $db.decisionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecisionsTableOrderingComposer
    extends Composer<_$GuardianDatabase, $DecisionsTable> {
  $$DecisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userChoice => $composableBuilder(
    column: $table.userChoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get waitUntil => $composableBuilder(
    column: $table.waitUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get satisfaction => $composableBuilder(
    column: $table.satisfaction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regretReason => $composableBuilder(
    column: $table.regretReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get risk => $composableBuilder(
    column: $table.risk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetImpact => $composableBuilder(
    column: $table.budgetImpact,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecisionsTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $DecisionsTable> {
  $$DecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<String> get userChoice => $composableBuilder(
    column: $table.userChoice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get waitUntil =>
      $composableBuilder(column: $table.waitUntil, builder: (column) => column);

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<String> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get satisfaction => $composableBuilder(
    column: $table.satisfaction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regretReason => $composableBuilder(
    column: $table.regretReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get risk =>
      $composableBuilder(column: $table.risk, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get budgetImpact => $composableBuilder(
    column: $table.budgetImpact,
    builder: (column) => column,
  );

  Expression<T> decisionEventsRefs<T extends Object>(
    Expression<T> Function($$DecisionEventsTableAnnotationComposer a) f,
  ) {
    final $$DecisionEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionEvents,
      getReferencedColumn: (t) => t.decisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.decisionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> decisionReferencesRefs<T extends Object>(
    Expression<T> Function($$DecisionReferencesTableAnnotationComposer a) f,
  ) {
    final $$DecisionReferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.decisionReferences,
          getReferencedColumn: (t) => t.decisionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DecisionReferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.decisionReferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> decisionAlternativesRefs<T extends Object>(
    Expression<T> Function($$DecisionAlternativesTableAnnotationComposer a) f,
  ) {
    final $$DecisionAlternativesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.decisionAlternatives,
          getReferencedColumn: (t) => t.decisionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DecisionAlternativesTableAnnotationComposer(
                $db: $db,
                $table: $db.decisionAlternatives,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> decisionTagsRefs<T extends Object>(
    Expression<T> Function($$DecisionTagsTableAnnotationComposer a) f,
  ) {
    final $$DecisionTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisionTags,
      getReferencedColumn: (t) => t.decisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.decisionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecisionsTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $DecisionsTable,
          StoredDecision,
          $$DecisionsTableFilterComposer,
          $$DecisionsTableOrderingComposer,
          $$DecisionsTableAnnotationComposer,
          $$DecisionsTableCreateCompanionBuilder,
          $$DecisionsTableUpdateCompanionBuilder,
          (StoredDecision, $$DecisionsTableReferences),
          StoredDecision,
          PrefetchHooks Function({
            bool decisionEventsRefs,
            bool decisionReferencesRefs,
            bool decisionAlternativesRefs,
            bool decisionTagsRefs,
          })
        > {
  $$DecisionsTableTableManager(_$GuardianDatabase db, $DecisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<String> userChoice = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> waitUntil = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String?> usageFrequency = const Value.absent(),
                Value<int?> satisfaction = const Value.absent(),
                Value<String?> regretReason = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> risk = const Value.absent(),
                Value<String?> confidence = const Value.absent(),
                Value<String?> budgetImpact = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionsCompanion(
                id: id,
                itemName: itemName,
                total: total,
                verdict: verdict,
                userChoice: userChoice,
                summary: summary,
                createdAt: createdAt,
                waitUntil: waitUntil,
                feedback: feedback,
                usageFrequency: usageFrequency,
                satisfaction: satisfaction,
                regretReason: regretReason,
                category: category,
                risk: risk,
                confidence: confidence,
                budgetImpact: budgetImpact,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemName,
                required double total,
                required String verdict,
                required String userChoice,
                required String summary,
                required DateTime createdAt,
                Value<DateTime?> waitUntil = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<String?> usageFrequency = const Value.absent(),
                Value<int?> satisfaction = const Value.absent(),
                Value<String?> regretReason = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> risk = const Value.absent(),
                Value<String?> confidence = const Value.absent(),
                Value<String?> budgetImpact = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionsCompanion.insert(
                id: id,
                itemName: itemName,
                total: total,
                verdict: verdict,
                userChoice: userChoice,
                summary: summary,
                createdAt: createdAt,
                waitUntil: waitUntil,
                feedback: feedback,
                usageFrequency: usageFrequency,
                satisfaction: satisfaction,
                regretReason: regretReason,
                category: category,
                risk: risk,
                confidence: confidence,
                budgetImpact: budgetImpact,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DecisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                decisionEventsRefs = false,
                decisionReferencesRefs = false,
                decisionAlternativesRefs = false,
                decisionTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (decisionEventsRefs) db.decisionEvents,
                    if (decisionReferencesRefs) db.decisionReferences,
                    if (decisionAlternativesRefs) db.decisionAlternatives,
                    if (decisionTagsRefs) db.decisionTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (decisionEventsRefs)
                        await $_getPrefetchedData<
                          StoredDecision,
                          $DecisionsTable,
                          StoredDecisionEvent
                        >(
                          currentTable: table,
                          referencedTable: $$DecisionsTableReferences
                              ._decisionEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).decisionEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.decisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (decisionReferencesRefs)
                        await $_getPrefetchedData<
                          StoredDecision,
                          $DecisionsTable,
                          StoredDecisionReference
                        >(
                          currentTable: table,
                          referencedTable: $$DecisionsTableReferences
                              ._decisionReferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).decisionReferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.decisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (decisionAlternativesRefs)
                        await $_getPrefetchedData<
                          StoredDecision,
                          $DecisionsTable,
                          StoredDecisionAlternative
                        >(
                          currentTable: table,
                          referencedTable: $$DecisionsTableReferences
                              ._decisionAlternativesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).decisionAlternativesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.decisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (decisionTagsRefs)
                        await $_getPrefetchedData<
                          StoredDecision,
                          $DecisionsTable,
                          StoredDecisionTag
                        >(
                          currentTable: table,
                          referencedTable: $$DecisionsTableReferences
                              ._decisionTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).decisionTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.decisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $DecisionsTable,
      StoredDecision,
      $$DecisionsTableFilterComposer,
      $$DecisionsTableOrderingComposer,
      $$DecisionsTableAnnotationComposer,
      $$DecisionsTableCreateCompanionBuilder,
      $$DecisionsTableUpdateCompanionBuilder,
      (StoredDecision, $$DecisionsTableReferences),
      StoredDecision,
      PrefetchHooks Function({
        bool decisionEventsRefs,
        bool decisionReferencesRefs,
        bool decisionAlternativesRefs,
        bool decisionTagsRefs,
      })
    >;
typedef $$DecisionEventsTableCreateCompanionBuilder =
    DecisionEventsCompanion Function({
      required String decisionId,
      required int position,
      required String status,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$DecisionEventsTableUpdateCompanionBuilder =
    DecisionEventsCompanion Function({
      Value<String> decisionId,
      Value<int> position,
      Value<String> status,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

final class $$DecisionEventsTableReferences
    extends
        BaseReferences<
          _$GuardianDatabase,
          $DecisionEventsTable,
          StoredDecisionEvent
        > {
  $$DecisionEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DecisionsTable _decisionIdTable(_$GuardianDatabase db) =>
      db.decisions.createAlias('decision_events__decision_id__decisions__id');

  $$DecisionsTableProcessedTableManager get decisionId {
    final $_column = $_itemColumn<String>('decision_id')!;

    final manager = $$DecisionsTableTableManager(
      $_db,
      $_db.decisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_decisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecisionEventsTableFilterComposer
    extends Composer<_$GuardianDatabase, $DecisionEventsTable> {
  $$DecisionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DecisionsTableFilterComposer get decisionId {
    final $$DecisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableFilterComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionEventsTableOrderingComposer
    extends Composer<_$GuardianDatabase, $DecisionEventsTable> {
  $$DecisionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecisionsTableOrderingComposer get decisionId {
    final $$DecisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableOrderingComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionEventsTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $DecisionEventsTable> {
  $$DecisionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  $$DecisionsTableAnnotationComposer get decisionId {
    final $$DecisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionEventsTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $DecisionEventsTable,
          StoredDecisionEvent,
          $$DecisionEventsTableFilterComposer,
          $$DecisionEventsTableOrderingComposer,
          $$DecisionEventsTableAnnotationComposer,
          $$DecisionEventsTableCreateCompanionBuilder,
          $$DecisionEventsTableUpdateCompanionBuilder,
          (StoredDecisionEvent, $$DecisionEventsTableReferences),
          StoredDecisionEvent,
          PrefetchHooks Function({bool decisionId})
        > {
  $$DecisionEventsTableTableManager(
    _$GuardianDatabase db,
    $DecisionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> decisionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionEventsCompanion(
                decisionId: decisionId,
                position: position,
                status: status,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String decisionId,
                required int position,
                required String status,
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => DecisionEventsCompanion.insert(
                decisionId: decisionId,
                position: position,
                status: status,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DecisionEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({decisionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (decisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.decisionId,
                                referencedTable: $$DecisionEventsTableReferences
                                    ._decisionIdTable(db),
                                referencedColumn:
                                    $$DecisionEventsTableReferences
                                        ._decisionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DecisionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $DecisionEventsTable,
      StoredDecisionEvent,
      $$DecisionEventsTableFilterComposer,
      $$DecisionEventsTableOrderingComposer,
      $$DecisionEventsTableAnnotationComposer,
      $$DecisionEventsTableCreateCompanionBuilder,
      $$DecisionEventsTableUpdateCompanionBuilder,
      (StoredDecisionEvent, $$DecisionEventsTableReferences),
      StoredDecisionEvent,
      PrefetchHooks Function({bool decisionId})
    >;
typedef $$DecisionReferencesTableCreateCompanionBuilder =
    DecisionReferencesCompanion Function({
      required String decisionId,
      required int position,
      required String summary,
      Value<int> rowid,
    });
typedef $$DecisionReferencesTableUpdateCompanionBuilder =
    DecisionReferencesCompanion Function({
      Value<String> decisionId,
      Value<int> position,
      Value<String> summary,
      Value<int> rowid,
    });

final class $$DecisionReferencesTableReferences
    extends
        BaseReferences<
          _$GuardianDatabase,
          $DecisionReferencesTable,
          StoredDecisionReference
        > {
  $$DecisionReferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DecisionsTable _decisionIdTable(_$GuardianDatabase db) => db.decisions
      .createAlias('decision_references__decision_id__decisions__id');

  $$DecisionsTableProcessedTableManager get decisionId {
    final $_column = $_itemColumn<String>('decision_id')!;

    final manager = $$DecisionsTableTableManager(
      $_db,
      $_db.decisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_decisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecisionReferencesTableFilterComposer
    extends Composer<_$GuardianDatabase, $DecisionReferencesTable> {
  $$DecisionReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  $$DecisionsTableFilterComposer get decisionId {
    final $$DecisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableFilterComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionReferencesTableOrderingComposer
    extends Composer<_$GuardianDatabase, $DecisionReferencesTable> {
  $$DecisionReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecisionsTableOrderingComposer get decisionId {
    final $$DecisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableOrderingComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionReferencesTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $DecisionReferencesTable> {
  $$DecisionReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  $$DecisionsTableAnnotationComposer get decisionId {
    final $$DecisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionReferencesTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $DecisionReferencesTable,
          StoredDecisionReference,
          $$DecisionReferencesTableFilterComposer,
          $$DecisionReferencesTableOrderingComposer,
          $$DecisionReferencesTableAnnotationComposer,
          $$DecisionReferencesTableCreateCompanionBuilder,
          $$DecisionReferencesTableUpdateCompanionBuilder,
          (StoredDecisionReference, $$DecisionReferencesTableReferences),
          StoredDecisionReference,
          PrefetchHooks Function({bool decisionId})
        > {
  $$DecisionReferencesTableTableManager(
    _$GuardianDatabase db,
    $DecisionReferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionReferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> decisionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionReferencesCompanion(
                decisionId: decisionId,
                position: position,
                summary: summary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String decisionId,
                required int position,
                required String summary,
                Value<int> rowid = const Value.absent(),
              }) => DecisionReferencesCompanion.insert(
                decisionId: decisionId,
                position: position,
                summary: summary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DecisionReferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({decisionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (decisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.decisionId,
                                referencedTable:
                                    $$DecisionReferencesTableReferences
                                        ._decisionIdTable(db),
                                referencedColumn:
                                    $$DecisionReferencesTableReferences
                                        ._decisionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DecisionReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $DecisionReferencesTable,
      StoredDecisionReference,
      $$DecisionReferencesTableFilterComposer,
      $$DecisionReferencesTableOrderingComposer,
      $$DecisionReferencesTableAnnotationComposer,
      $$DecisionReferencesTableCreateCompanionBuilder,
      $$DecisionReferencesTableUpdateCompanionBuilder,
      (StoredDecisionReference, $$DecisionReferencesTableReferences),
      StoredDecisionReference,
      PrefetchHooks Function({bool decisionId})
    >;
typedef $$DecisionAlternativesTableCreateCompanionBuilder =
    DecisionAlternativesCompanion Function({
      required String decisionId,
      required int position,
      required String description,
      Value<int> rowid,
    });
typedef $$DecisionAlternativesTableUpdateCompanionBuilder =
    DecisionAlternativesCompanion Function({
      Value<String> decisionId,
      Value<int> position,
      Value<String> description,
      Value<int> rowid,
    });

final class $$DecisionAlternativesTableReferences
    extends
        BaseReferences<
          _$GuardianDatabase,
          $DecisionAlternativesTable,
          StoredDecisionAlternative
        > {
  $$DecisionAlternativesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DecisionsTable _decisionIdTable(_$GuardianDatabase db) => db.decisions
      .createAlias('decision_alternatives__decision_id__decisions__id');

  $$DecisionsTableProcessedTableManager get decisionId {
    final $_column = $_itemColumn<String>('decision_id')!;

    final manager = $$DecisionsTableTableManager(
      $_db,
      $_db.decisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_decisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecisionAlternativesTableFilterComposer
    extends Composer<_$GuardianDatabase, $DecisionAlternativesTable> {
  $$DecisionAlternativesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$DecisionsTableFilterComposer get decisionId {
    final $$DecisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableFilterComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionAlternativesTableOrderingComposer
    extends Composer<_$GuardianDatabase, $DecisionAlternativesTable> {
  $$DecisionAlternativesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecisionsTableOrderingComposer get decisionId {
    final $$DecisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableOrderingComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionAlternativesTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $DecisionAlternativesTable> {
  $$DecisionAlternativesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$DecisionsTableAnnotationComposer get decisionId {
    final $$DecisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionAlternativesTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $DecisionAlternativesTable,
          StoredDecisionAlternative,
          $$DecisionAlternativesTableFilterComposer,
          $$DecisionAlternativesTableOrderingComposer,
          $$DecisionAlternativesTableAnnotationComposer,
          $$DecisionAlternativesTableCreateCompanionBuilder,
          $$DecisionAlternativesTableUpdateCompanionBuilder,
          (StoredDecisionAlternative, $$DecisionAlternativesTableReferences),
          StoredDecisionAlternative,
          PrefetchHooks Function({bool decisionId})
        > {
  $$DecisionAlternativesTableTableManager(
    _$GuardianDatabase db,
    $DecisionAlternativesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionAlternativesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionAlternativesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DecisionAlternativesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> decisionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionAlternativesCompanion(
                decisionId: decisionId,
                position: position,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String decisionId,
                required int position,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => DecisionAlternativesCompanion.insert(
                decisionId: decisionId,
                position: position,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DecisionAlternativesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({decisionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (decisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.decisionId,
                                referencedTable:
                                    $$DecisionAlternativesTableReferences
                                        ._decisionIdTable(db),
                                referencedColumn:
                                    $$DecisionAlternativesTableReferences
                                        ._decisionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DecisionAlternativesTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $DecisionAlternativesTable,
      StoredDecisionAlternative,
      $$DecisionAlternativesTableFilterComposer,
      $$DecisionAlternativesTableOrderingComposer,
      $$DecisionAlternativesTableAnnotationComposer,
      $$DecisionAlternativesTableCreateCompanionBuilder,
      $$DecisionAlternativesTableUpdateCompanionBuilder,
      (StoredDecisionAlternative, $$DecisionAlternativesTableReferences),
      StoredDecisionAlternative,
      PrefetchHooks Function({bool decisionId})
    >;
typedef $$DecisionTagsTableCreateCompanionBuilder =
    DecisionTagsCompanion Function({
      required String decisionId,
      required int position,
      required String tag,
      Value<int> rowid,
    });
typedef $$DecisionTagsTableUpdateCompanionBuilder =
    DecisionTagsCompanion Function({
      Value<String> decisionId,
      Value<int> position,
      Value<String> tag,
      Value<int> rowid,
    });

final class $$DecisionTagsTableReferences
    extends
        BaseReferences<
          _$GuardianDatabase,
          $DecisionTagsTable,
          StoredDecisionTag
        > {
  $$DecisionTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecisionsTable _decisionIdTable(_$GuardianDatabase db) =>
      db.decisions.createAlias('decision_tags__decision_id__decisions__id');

  $$DecisionsTableProcessedTableManager get decisionId {
    final $_column = $_itemColumn<String>('decision_id')!;

    final manager = $$DecisionsTableTableManager(
      $_db,
      $_db.decisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_decisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecisionTagsTableFilterComposer
    extends Composer<_$GuardianDatabase, $DecisionTagsTable> {
  $$DecisionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  $$DecisionsTableFilterComposer get decisionId {
    final $$DecisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableFilterComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionTagsTableOrderingComposer
    extends Composer<_$GuardianDatabase, $DecisionTagsTable> {
  $$DecisionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecisionsTableOrderingComposer get decisionId {
    final $$DecisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableOrderingComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionTagsTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $DecisionTagsTable> {
  $$DecisionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  $$DecisionsTableAnnotationComposer get decisionId {
    final $$DecisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.decisionId,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionTagsTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $DecisionTagsTable,
          StoredDecisionTag,
          $$DecisionTagsTableFilterComposer,
          $$DecisionTagsTableOrderingComposer,
          $$DecisionTagsTableAnnotationComposer,
          $$DecisionTagsTableCreateCompanionBuilder,
          $$DecisionTagsTableUpdateCompanionBuilder,
          (StoredDecisionTag, $$DecisionTagsTableReferences),
          StoredDecisionTag,
          PrefetchHooks Function({bool decisionId})
        > {
  $$DecisionTagsTableTableManager(
    _$GuardianDatabase db,
    $DecisionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> decisionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionTagsCompanion(
                decisionId: decisionId,
                position: position,
                tag: tag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String decisionId,
                required int position,
                required String tag,
                Value<int> rowid = const Value.absent(),
              }) => DecisionTagsCompanion.insert(
                decisionId: decisionId,
                position: position,
                tag: tag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DecisionTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({decisionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (decisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.decisionId,
                                referencedTable: $$DecisionTagsTableReferences
                                    ._decisionIdTable(db),
                                referencedColumn: $$DecisionTagsTableReferences
                                    ._decisionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DecisionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $DecisionTagsTable,
      StoredDecisionTag,
      $$DecisionTagsTableFilterComposer,
      $$DecisionTagsTableOrderingComposer,
      $$DecisionTagsTableAnnotationComposer,
      $$DecisionTagsTableCreateCompanionBuilder,
      $$DecisionTagsTableUpdateCompanionBuilder,
      (StoredDecisionTag, $$DecisionTagsTableReferences),
      StoredDecisionTag,
      PrefetchHooks Function({bool decisionId})
    >;
typedef $$ConsumptionRulesTableCreateCompanionBuilder =
    ConsumptionRulesCompanion Function({
      required String id,
      required String name,
      required String description,
      Value<double?> minimumAmount,
      Value<int?> waitDays,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$ConsumptionRulesTableUpdateCompanionBuilder =
    ConsumptionRulesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<double?> minimumAmount,
      Value<int?> waitDays,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$ConsumptionRulesTableFilterComposer
    extends Composer<_$GuardianDatabase, $ConsumptionRulesTable> {
  $$ConsumptionRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumAmount => $composableBuilder(
    column: $table.minimumAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waitDays => $composableBuilder(
    column: $table.waitDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsumptionRulesTableOrderingComposer
    extends Composer<_$GuardianDatabase, $ConsumptionRulesTable> {
  $$ConsumptionRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumAmount => $composableBuilder(
    column: $table.minimumAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waitDays => $composableBuilder(
    column: $table.waitDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsumptionRulesTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $ConsumptionRulesTable> {
  $$ConsumptionRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minimumAmount => $composableBuilder(
    column: $table.minimumAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get waitDays =>
      $composableBuilder(column: $table.waitDays, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$ConsumptionRulesTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $ConsumptionRulesTable,
          StoredConsumptionRule,
          $$ConsumptionRulesTableFilterComposer,
          $$ConsumptionRulesTableOrderingComposer,
          $$ConsumptionRulesTableAnnotationComposer,
          $$ConsumptionRulesTableCreateCompanionBuilder,
          $$ConsumptionRulesTableUpdateCompanionBuilder,
          (
            StoredConsumptionRule,
            BaseReferences<
              _$GuardianDatabase,
              $ConsumptionRulesTable,
              StoredConsumptionRule
            >,
          ),
          StoredConsumptionRule,
          PrefetchHooks Function()
        > {
  $$ConsumptionRulesTableTableManager(
    _$GuardianDatabase db,
    $ConsumptionRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsumptionRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsumptionRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsumptionRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double?> minimumAmount = const Value.absent(),
                Value<int?> waitDays = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsumptionRulesCompanion(
                id: id,
                name: name,
                description: description,
                minimumAmount: minimumAmount,
                waitDays: waitDays,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                Value<double?> minimumAmount = const Value.absent(),
                Value<int?> waitDays = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsumptionRulesCompanion.insert(
                id: id,
                name: name,
                description: description,
                minimumAmount: minimumAmount,
                waitDays: waitDays,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsumptionRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $ConsumptionRulesTable,
      StoredConsumptionRule,
      $$ConsumptionRulesTableFilterComposer,
      $$ConsumptionRulesTableOrderingComposer,
      $$ConsumptionRulesTableAnnotationComposer,
      $$ConsumptionRulesTableCreateCompanionBuilder,
      $$ConsumptionRulesTableUpdateCompanionBuilder,
      (
        StoredConsumptionRule,
        BaseReferences<
          _$GuardianDatabase,
          $ConsumptionRulesTable,
          StoredConsumptionRule
        >,
      ),
      StoredConsumptionRule,
      PrefetchHooks Function()
    >;
typedef $$AppValuesTableCreateCompanionBuilder =
    AppValuesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppValuesTableUpdateCompanionBuilder =
    AppValuesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppValuesTableFilterComposer
    extends Composer<_$GuardianDatabase, $AppValuesTable> {
  $$AppValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppValuesTableOrderingComposer
    extends Composer<_$GuardianDatabase, $AppValuesTable> {
  $$AppValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppValuesTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $AppValuesTable> {
  $$AppValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppValuesTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $AppValuesTable,
          AppValue,
          $$AppValuesTableFilterComposer,
          $$AppValuesTableOrderingComposer,
          $$AppValuesTableAnnotationComposer,
          $$AppValuesTableCreateCompanionBuilder,
          $$AppValuesTableUpdateCompanionBuilder,
          (
            AppValue,
            BaseReferences<_$GuardianDatabase, $AppValuesTable, AppValue>,
          ),
          AppValue,
          PrefetchHooks Function()
        > {
  $$AppValuesTableTableManager(_$GuardianDatabase db, $AppValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppValuesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $AppValuesTable,
      AppValue,
      $$AppValuesTableFilterComposer,
      $$AppValuesTableOrderingComposer,
      $$AppValuesTableAnnotationComposer,
      $$AppValuesTableCreateCompanionBuilder,
      $$AppValuesTableUpdateCompanionBuilder,
      (AppValue, BaseReferences<_$GuardianDatabase, $AppValuesTable, AppValue>),
      AppValue,
      PrefetchHooks Function()
    >;
typedef $$MigrationQuarantineTableCreateCompanionBuilder =
    MigrationQuarantineCompanion Function({
      Value<int> id,
      required String sourceKey,
      required String rawValue,
      required String error,
      required DateTime quarantinedAt,
    });
typedef $$MigrationQuarantineTableUpdateCompanionBuilder =
    MigrationQuarantineCompanion Function({
      Value<int> id,
      Value<String> sourceKey,
      Value<String> rawValue,
      Value<String> error,
      Value<DateTime> quarantinedAt,
    });

class $$MigrationQuarantineTableFilterComposer
    extends Composer<_$GuardianDatabase, $MigrationQuarantineTable> {
  $$MigrationQuarantineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawValue => $composableBuilder(
    column: $table.rawValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MigrationQuarantineTableOrderingComposer
    extends Composer<_$GuardianDatabase, $MigrationQuarantineTable> {
  $$MigrationQuarantineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawValue => $composableBuilder(
    column: $table.rawValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MigrationQuarantineTableAnnotationComposer
    extends Composer<_$GuardianDatabase, $MigrationQuarantineTable> {
  $$MigrationQuarantineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<String> get rawValue =>
      $composableBuilder(column: $table.rawValue, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get quarantinedAt => $composableBuilder(
    column: $table.quarantinedAt,
    builder: (column) => column,
  );
}

class $$MigrationQuarantineTableTableManager
    extends
        RootTableManager<
          _$GuardianDatabase,
          $MigrationQuarantineTable,
          MigrationQuarantineData,
          $$MigrationQuarantineTableFilterComposer,
          $$MigrationQuarantineTableOrderingComposer,
          $$MigrationQuarantineTableAnnotationComposer,
          $$MigrationQuarantineTableCreateCompanionBuilder,
          $$MigrationQuarantineTableUpdateCompanionBuilder,
          (
            MigrationQuarantineData,
            BaseReferences<
              _$GuardianDatabase,
              $MigrationQuarantineTable,
              MigrationQuarantineData
            >,
          ),
          MigrationQuarantineData,
          PrefetchHooks Function()
        > {
  $$MigrationQuarantineTableTableManager(
    _$GuardianDatabase db,
    $MigrationQuarantineTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MigrationQuarantineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MigrationQuarantineTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MigrationQuarantineTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<String> rawValue = const Value.absent(),
                Value<String> error = const Value.absent(),
                Value<DateTime> quarantinedAt = const Value.absent(),
              }) => MigrationQuarantineCompanion(
                id: id,
                sourceKey: sourceKey,
                rawValue: rawValue,
                error: error,
                quarantinedAt: quarantinedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceKey,
                required String rawValue,
                required String error,
                required DateTime quarantinedAt,
              }) => MigrationQuarantineCompanion.insert(
                id: id,
                sourceKey: sourceKey,
                rawValue: rawValue,
                error: error,
                quarantinedAt: quarantinedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MigrationQuarantineTableProcessedTableManager =
    ProcessedTableManager<
      _$GuardianDatabase,
      $MigrationQuarantineTable,
      MigrationQuarantineData,
      $$MigrationQuarantineTableFilterComposer,
      $$MigrationQuarantineTableOrderingComposer,
      $$MigrationQuarantineTableAnnotationComposer,
      $$MigrationQuarantineTableCreateCompanionBuilder,
      $$MigrationQuarantineTableUpdateCompanionBuilder,
      (
        MigrationQuarantineData,
        BaseReferences<
          _$GuardianDatabase,
          $MigrationQuarantineTable,
          MigrationQuarantineData
        >,
      ),
      MigrationQuarantineData,
      PrefetchHooks Function()
    >;

class $GuardianDatabaseManager {
  final _$GuardianDatabase _db;
  $GuardianDatabaseManager(this._db);
  $$DecisionsTableTableManager get decisions =>
      $$DecisionsTableTableManager(_db, _db.decisions);
  $$DecisionEventsTableTableManager get decisionEvents =>
      $$DecisionEventsTableTableManager(_db, _db.decisionEvents);
  $$DecisionReferencesTableTableManager get decisionReferences =>
      $$DecisionReferencesTableTableManager(_db, _db.decisionReferences);
  $$DecisionAlternativesTableTableManager get decisionAlternatives =>
      $$DecisionAlternativesTableTableManager(_db, _db.decisionAlternatives);
  $$DecisionTagsTableTableManager get decisionTags =>
      $$DecisionTagsTableTableManager(_db, _db.decisionTags);
  $$ConsumptionRulesTableTableManager get consumptionRules =>
      $$ConsumptionRulesTableTableManager(_db, _db.consumptionRules);
  $$AppValuesTableTableManager get appValues =>
      $$AppValuesTableTableManager(_db, _db.appValues);
  $$MigrationQuarantineTableTableManager get migrationQuarantine =>
      $$MigrationQuarantineTableTableManager(_db, _db.migrationQuarantine);
}
