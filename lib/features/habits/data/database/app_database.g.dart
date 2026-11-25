// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HabitsTableTable extends HabitsTable
    with TableInfo<$HabitsTableTable, HabitsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week',
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
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _targetPerDayMeta = const VerificationMeta(
    'targetPerDay',
  );
  @override
  late final GeneratedColumn<int> targetPerDay = GeneratedColumn<int>(
    'target_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyFreezesAllowedMeta =
      const VerificationMeta('monthlyFreezesAllowed');
  @override
  late final GeneratedColumn<int> monthlyFreezesAllowed = GeneratedColumn<int>(
    'monthly_freezes_allowed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    scheduleType,
    daysOfWeek,
    createdAt,
    isArchived,
    targetPerDay,
    reminderTime,
    monthlyFreezesAllowed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleTypeMeta);
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysOfWeekMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('target_per_day')) {
      context.handle(
        _targetPerDayMeta,
        targetPerDay.isAcceptableOrUnknown(
          data['target_per_day']!,
          _targetPerDayMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('monthly_freezes_allowed')) {
      context.handle(
        _monthlyFreezesAllowedMeta,
        monthlyFreezesAllowed.isAcceptableOrUnknown(
          data['monthly_freezes_allowed']!,
          _monthlyFreezesAllowedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      scheduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_type'],
      )!,
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      targetPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_per_day'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      monthlyFreezesAllowed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_freezes_allowed'],
      )!,
    );
  }

  @override
  $HabitsTableTable createAlias(String alias) {
    return $HabitsTableTable(attachedDatabase, alias);
  }
}

class HabitsTableData extends DataClass implements Insertable<HabitsTableData> {
  final String id;
  final String title;
  final String description;
  final String scheduleType;
  final String daysOfWeek;
  final DateTime createdAt;
  final bool isArchived;
  final int targetPerDay;
  final String? reminderTime;
  final int monthlyFreezesAllowed;
  const HabitsTableData({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduleType,
    required this.daysOfWeek,
    required this.createdAt,
    required this.isArchived,
    required this.targetPerDay,
    this.reminderTime,
    required this.monthlyFreezesAllowed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['schedule_type'] = Variable<String>(scheduleType);
    map['days_of_week'] = Variable<String>(daysOfWeek);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_archived'] = Variable<bool>(isArchived);
    map['target_per_day'] = Variable<int>(targetPerDay);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    map['monthly_freezes_allowed'] = Variable<int>(monthlyFreezesAllowed);
    return map;
  }

  HabitsTableCompanion toCompanion(bool nullToAbsent) {
    return HabitsTableCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      scheduleType: Value(scheduleType),
      daysOfWeek: Value(daysOfWeek),
      createdAt: Value(createdAt),
      isArchived: Value(isArchived),
      targetPerDay: Value(targetPerDay),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      monthlyFreezesAllowed: Value(monthlyFreezesAllowed),
    );
  }

  factory HabitsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      daysOfWeek: serializer.fromJson<String>(json['daysOfWeek']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      targetPerDay: serializer.fromJson<int>(json['targetPerDay']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      monthlyFreezesAllowed: serializer.fromJson<int>(
        json['monthlyFreezesAllowed'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'daysOfWeek': serializer.toJson<String>(daysOfWeek),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'targetPerDay': serializer.toJson<int>(targetPerDay),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'monthlyFreezesAllowed': serializer.toJson<int>(monthlyFreezesAllowed),
    };
  }

  HabitsTableData copyWith({
    String? id,
    String? title,
    String? description,
    String? scheduleType,
    String? daysOfWeek,
    DateTime? createdAt,
    bool? isArchived,
    int? targetPerDay,
    Value<String?> reminderTime = const Value.absent(),
    int? monthlyFreezesAllowed,
  }) => HabitsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    scheduleType: scheduleType ?? this.scheduleType,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    createdAt: createdAt ?? this.createdAt,
    isArchived: isArchived ?? this.isArchived,
    targetPerDay: targetPerDay ?? this.targetPerDay,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    monthlyFreezesAllowed: monthlyFreezesAllowed ?? this.monthlyFreezesAllowed,
  );
  HabitsTableData copyWithCompanion(HabitsTableCompanion data) {
    return HabitsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      targetPerDay: data.targetPerDay.present
          ? data.targetPerDay.value
          : this.targetPerDay,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      monthlyFreezesAllowed: data.monthlyFreezesAllowed.present
          ? data.monthlyFreezesAllowed.value
          : this.monthlyFreezesAllowed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('targetPerDay: $targetPerDay, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('monthlyFreezesAllowed: $monthlyFreezesAllowed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    scheduleType,
    daysOfWeek,
    createdAt,
    isArchived,
    targetPerDay,
    reminderTime,
    monthlyFreezesAllowed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.scheduleType == this.scheduleType &&
          other.daysOfWeek == this.daysOfWeek &&
          other.createdAt == this.createdAt &&
          other.isArchived == this.isArchived &&
          other.targetPerDay == this.targetPerDay &&
          other.reminderTime == this.reminderTime &&
          other.monthlyFreezesAllowed == this.monthlyFreezesAllowed);
}

class HabitsTableCompanion extends UpdateCompanion<HabitsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> scheduleType;
  final Value<String> daysOfWeek;
  final Value<DateTime> createdAt;
  final Value<bool> isArchived;
  final Value<int> targetPerDay;
  final Value<String?> reminderTime;
  final Value<int> monthlyFreezesAllowed;
  final Value<int> rowid;
  const HabitsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.targetPerDay = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.monthlyFreezesAllowed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsTableCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String scheduleType,
    required String daysOfWeek,
    required DateTime createdAt,
    this.isArchived = const Value.absent(),
    this.targetPerDay = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.monthlyFreezesAllowed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       scheduleType = Value(scheduleType),
       daysOfWeek = Value(daysOfWeek),
       createdAt = Value(createdAt);
  static Insertable<HabitsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? scheduleType,
    Expression<String>? daysOfWeek,
    Expression<DateTime>? createdAt,
    Expression<bool>? isArchived,
    Expression<int>? targetPerDay,
    Expression<String>? reminderTime,
    Expression<int>? monthlyFreezesAllowed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (createdAt != null) 'created_at': createdAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (targetPerDay != null) 'target_per_day': targetPerDay,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (monthlyFreezesAllowed != null)
        'monthly_freezes_allowed': monthlyFreezesAllowed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? scheduleType,
    Value<String>? daysOfWeek,
    Value<DateTime>? createdAt,
    Value<bool>? isArchived,
    Value<int>? targetPerDay,
    Value<String?>? reminderTime,
    Value<int>? monthlyFreezesAllowed,
    Value<int>? rowid,
  }) {
    return HabitsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduleType: scheduleType ?? this.scheduleType,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      reminderTime: reminderTime ?? this.reminderTime,
      monthlyFreezesAllowed:
          monthlyFreezesAllowed ?? this.monthlyFreezesAllowed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (targetPerDay.present) {
      map['target_per_day'] = Variable<int>(targetPerDay.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (monthlyFreezesAllowed.present) {
      map['monthly_freezes_allowed'] = Variable<int>(
        monthlyFreezesAllowed.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('targetPerDay: $targetPerDay, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('monthlyFreezesAllowed: $monthlyFreezesAllowed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTableTable extends CompletionsTable
    with TableInfo<$CompletionsTableTable, CompletionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFrozenMeta = const VerificationMeta(
    'isFrozen',
  );
  @override
  late final GeneratedColumn<bool> isFrozen = GeneratedColumn<bool>(
    'is_frozen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_frozen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    date,
    isFrozen,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_frozen')) {
      context.handle(
        _isFrozenMeta,
        isFrozen.isAcceptableOrUnknown(data['is_frozen']!, _isFrozenMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      isFrozen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_frozen'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $CompletionsTableTable createAlias(String alias) {
    return $CompletionsTableTable(attachedDatabase, alias);
  }
}

class CompletionsTableData extends DataClass
    implements Insertable<CompletionsTableData> {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isFrozen;
  final DateTime recordedAt;
  const CompletionsTableData({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isFrozen,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['is_frozen'] = Variable<bool>(isFrozen);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  CompletionsTableCompanion toCompanion(bool nullToAbsent) {
    return CompletionsTableCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      isFrozen: Value(isFrozen),
      recordedAt: Value(recordedAt),
    );
  }

  factory CompletionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionsTableData(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      isFrozen: serializer.fromJson<bool>(json['isFrozen']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'isFrozen': serializer.toJson<bool>(isFrozen),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  CompletionsTableData copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isFrozen,
    DateTime? recordedAt,
  }) => CompletionsTableData(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    isFrozen: isFrozen ?? this.isFrozen,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  CompletionsTableData copyWithCompanion(CompletionsTableCompanion data) {
    return CompletionsTableData(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      isFrozen: data.isFrozen.present ? data.isFrozen.value : this.isFrozen,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsTableData(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('isFrozen: $isFrozen, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, date, isFrozen, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionsTableData &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.isFrozen == this.isFrozen &&
          other.recordedAt == this.recordedAt);
}

class CompletionsTableCompanion extends UpdateCompanion<CompletionsTableData> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> date;
  final Value<bool> isFrozen;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const CompletionsTableCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.isFrozen = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsTableCompanion.insert({
    required String id,
    required String habitId,
    required DateTime date,
    this.isFrozen = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       date = Value(date),
       recordedAt = Value(recordedAt);
  static Insertable<CompletionsTableData> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? date,
    Expression<bool>? isFrozen,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (isFrozen != null) 'is_frozen': isFrozen,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? date,
    Value<bool>? isFrozen,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return CompletionsTableCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isFrozen: isFrozen ?? this.isFrozen,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isFrozen.present) {
      map['is_frozen'] = Variable<bool>(isFrozen.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsTableCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('isFrozen: $isFrozen, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTableTable habitsTable = $HabitsTableTable(this);
  late final $CompletionsTableTable completionsTable = $CompletionsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habitsTable,
    completionsTable,
  ];
}

typedef $$HabitsTableTableCreateCompanionBuilder =
    HabitsTableCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      required String scheduleType,
      required String daysOfWeek,
      required DateTime createdAt,
      Value<bool> isArchived,
      Value<int> targetPerDay,
      Value<String?> reminderTime,
      Value<int> monthlyFreezesAllowed,
      Value<int> rowid,
    });
typedef $$HabitsTableTableUpdateCompanionBuilder =
    HabitsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<String> scheduleType,
      Value<String> daysOfWeek,
      Value<DateTime> createdAt,
      Value<bool> isArchived,
      Value<int> targetPerDay,
      Value<String?> reminderTime,
      Value<int> monthlyFreezesAllowed,
      Value<int> rowid,
    });

class $$HabitsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPerDay => $composableBuilder(
    column: $table.targetPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyFreezesAllowed => $composableBuilder(
    column: $table.monthlyFreezesAllowed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPerDay => $composableBuilder(
    column: $table.targetPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyFreezesAllowed => $composableBuilder(
    column: $table.monthlyFreezesAllowed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPerDay => $composableBuilder(
    column: $table.targetPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyFreezesAllowed => $composableBuilder(
    column: $table.monthlyFreezesAllowed,
    builder: (column) => column,
  );
}

class $$HabitsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTableTable,
          HabitsTableData,
          $$HabitsTableTableFilterComposer,
          $$HabitsTableTableOrderingComposer,
          $$HabitsTableTableAnnotationComposer,
          $$HabitsTableTableCreateCompanionBuilder,
          $$HabitsTableTableUpdateCompanionBuilder,
          (
            HabitsTableData,
            BaseReferences<_$AppDatabase, $HabitsTableTable, HabitsTableData>,
          ),
          HabitsTableData,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableTableManager(_$AppDatabase db, $HabitsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String> daysOfWeek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> targetPerDay = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int> monthlyFreezesAllowed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsTableCompanion(
                id: id,
                title: title,
                description: description,
                scheduleType: scheduleType,
                daysOfWeek: daysOfWeek,
                createdAt: createdAt,
                isArchived: isArchived,
                targetPerDay: targetPerDay,
                reminderTime: reminderTime,
                monthlyFreezesAllowed: monthlyFreezesAllowed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                required String scheduleType,
                required String daysOfWeek,
                required DateTime createdAt,
                Value<bool> isArchived = const Value.absent(),
                Value<int> targetPerDay = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int> monthlyFreezesAllowed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsTableCompanion.insert(
                id: id,
                title: title,
                description: description,
                scheduleType: scheduleType,
                daysOfWeek: daysOfWeek,
                createdAt: createdAt,
                isArchived: isArchived,
                targetPerDay: targetPerDay,
                reminderTime: reminderTime,
                monthlyFreezesAllowed: monthlyFreezesAllowed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTableTable, HabitsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HabitsTableTable,
                    HabitsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTableTable,
      HabitsTableData,
      $$HabitsTableTableFilterComposer,
      $$HabitsTableTableOrderingComposer,
      $$HabitsTableTableAnnotationComposer,
      $$HabitsTableTableCreateCompanionBuilder,
      $$HabitsTableTableUpdateCompanionBuilder,
      (
        HabitsTableData,
        BaseReferences<_$AppDatabase, $HabitsTableTable, HabitsTableData>,
      ),
      HabitsTableData,
      PrefetchHooks Function()
    >;
typedef $$CompletionsTableTableCreateCompanionBuilder =
    CompletionsTableCompanion Function({
      required String id,
      required String habitId,
      required DateTime date,
      Value<bool> isFrozen,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$CompletionsTableTableUpdateCompanionBuilder =
    CompletionsTableCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> date,
      Value<bool> isFrozen,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$CompletionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionsTableTable> {
  $$CompletionsTableTableFilterComposer({
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

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFrozen => $composableBuilder(
    column: $table.isFrozen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionsTableTable> {
  $$CompletionsTableTableOrderingComposer({
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

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFrozen => $composableBuilder(
    column: $table.isFrozen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionsTableTable> {
  $$CompletionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isFrozen =>
      $composableBuilder(column: $table.isFrozen, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$CompletionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionsTableTable,
          CompletionsTableData,
          $$CompletionsTableTableFilterComposer,
          $$CompletionsTableTableOrderingComposer,
          $$CompletionsTableTableAnnotationComposer,
          $$CompletionsTableTableCreateCompanionBuilder,
          $$CompletionsTableTableUpdateCompanionBuilder,
          (
            CompletionsTableData,
            BaseReferences<
              _$AppDatabase,
              $CompletionsTableTable,
              CompletionsTableData
            >,
          ),
          CompletionsTableData,
          PrefetchHooks Function()
        > {
  $$CompletionsTableTableTableManager(
    _$AppDatabase db,
    $CompletionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isFrozen = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsTableCompanion(
                id: id,
                habitId: habitId,
                date: date,
                isFrozen: isFrozen,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime date,
                Value<bool> isFrozen = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => CompletionsTableCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                isFrozen: isFrozen,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionsTableTable, CompletionsTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletionsTableTable,
                    CompletionsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionsTableTable,
      CompletionsTableData,
      $$CompletionsTableTableFilterComposer,
      $$CompletionsTableTableOrderingComposer,
      $$CompletionsTableTableAnnotationComposer,
      $$CompletionsTableTableCreateCompanionBuilder,
      $$CompletionsTableTableUpdateCompanionBuilder,
      (
        CompletionsTableData,
        BaseReferences<
          _$AppDatabase,
          $CompletionsTableTable,
          CompletionsTableData
        >,
      ),
      CompletionsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableTableManager get habitsTable =>
      $$HabitsTableTableTableManager(_db, _db.habitsTable);
  $$CompletionsTableTableTableManager get completionsTable =>
      $$CompletionsTableTableTableManager(_db, _db.completionsTable);
}
