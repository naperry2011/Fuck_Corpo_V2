// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<BreakMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BreakMode>($SessionsTable.$convertermode);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedMeta = const VerificationMeta('earned');
  @override
  late final GeneratedColumn<double> earned = GeneratedColumn<double>(
    'earned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BusinessCategory?, String>
  businessCategory =
      GeneratedColumn<String>(
        'business_category',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<BusinessCategory?>(
        $SessionsTable.$converterbusinessCategoryn,
      );
  static const VerificationMeta _damagesMeta = const VerificationMeta(
    'damages',
  );
  @override
  late final GeneratedColumn<double> damages = GeneratedColumn<double>(
    'damages',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    startedAt,
    durationMs,
    earned,
    businessName,
    businessCategory,
    damages,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('earned')) {
      context.handle(
        _earnedMeta,
        earned.isAcceptableOrUnknown(data['earned']!, _earnedMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedMeta);
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    }
    if (data.containsKey('damages')) {
      context.handle(
        _damagesMeta,
        damages.isAcceptableOrUnknown(data['damages']!, _damagesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: $SessionsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      earned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}earned'],
      )!,
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      ),
      businessCategory: $SessionsTable.$converterbusinessCategoryn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}business_category'],
        ),
      ),
      damages: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}damages'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BreakMode, String, String> $convertermode =
      const EnumNameConverter<BreakMode>(BreakMode.values);
  static JsonTypeConverter2<BusinessCategory, String, String>
  $converterbusinessCategory = const EnumNameConverter<BusinessCategory>(
    BusinessCategory.values,
  );
  static JsonTypeConverter2<BusinessCategory?, String?, String?>
  $converterbusinessCategoryn = JsonTypeConverter2.asNullable(
    $converterbusinessCategory,
  );
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final BreakMode mode;
  final DateTime startedAt;
  final int durationMs;
  final double earned;
  final String? businessName;
  final BusinessCategory? businessCategory;
  final double? damages;
  const Session({
    required this.id,
    required this.mode,
    required this.startedAt,
    required this.durationMs,
    required this.earned,
    this.businessName,
    this.businessCategory,
    this.damages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['mode'] = Variable<String>($SessionsTable.$convertermode.toSql(mode));
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['earned'] = Variable<double>(earned);
    if (!nullToAbsent || businessName != null) {
      map['business_name'] = Variable<String>(businessName);
    }
    if (!nullToAbsent || businessCategory != null) {
      map['business_category'] = Variable<String>(
        $SessionsTable.$converterbusinessCategoryn.toSql(businessCategory),
      );
    }
    if (!nullToAbsent || damages != null) {
      map['damages'] = Variable<double>(damages);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      mode: Value(mode),
      startedAt: Value(startedAt),
      durationMs: Value(durationMs),
      earned: Value(earned),
      businessName: businessName == null && nullToAbsent
          ? const Value.absent()
          : Value(businessName),
      businessCategory: businessCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(businessCategory),
      damages: damages == null && nullToAbsent
          ? const Value.absent()
          : Value(damages),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      mode: $SessionsTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      earned: serializer.fromJson<double>(json['earned']),
      businessName: serializer.fromJson<String?>(json['businessName']),
      businessCategory: $SessionsTable.$converterbusinessCategoryn.fromJson(
        serializer.fromJson<String?>(json['businessCategory']),
      ),
      damages: serializer.fromJson<double?>(json['damages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<String>(
        $SessionsTable.$convertermode.toJson(mode),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'earned': serializer.toJson<double>(earned),
      'businessName': serializer.toJson<String?>(businessName),
      'businessCategory': serializer.toJson<String?>(
        $SessionsTable.$converterbusinessCategoryn.toJson(businessCategory),
      ),
      'damages': serializer.toJson<double?>(damages),
    };
  }

  Session copyWith({
    int? id,
    BreakMode? mode,
    DateTime? startedAt,
    int? durationMs,
    double? earned,
    Value<String?> businessName = const Value.absent(),
    Value<BusinessCategory?> businessCategory = const Value.absent(),
    Value<double?> damages = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    startedAt: startedAt ?? this.startedAt,
    durationMs: durationMs ?? this.durationMs,
    earned: earned ?? this.earned,
    businessName: businessName.present ? businessName.value : this.businessName,
    businessCategory: businessCategory.present
        ? businessCategory.value
        : this.businessCategory,
    damages: damages.present ? damages.value : this.damages,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      earned: data.earned.present ? data.earned.value : this.earned,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      businessCategory: data.businessCategory.present
          ? data.businessCategory.value
          : this.businessCategory,
      damages: data.damages.present ? data.damages.value : this.damages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('earned: $earned, ')
          ..write('businessName: $businessName, ')
          ..write('businessCategory: $businessCategory, ')
          ..write('damages: $damages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    startedAt,
    durationMs,
    earned,
    businessName,
    businessCategory,
    damages,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.startedAt == this.startedAt &&
          other.durationMs == this.durationMs &&
          other.earned == this.earned &&
          other.businessName == this.businessName &&
          other.businessCategory == this.businessCategory &&
          other.damages == this.damages);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<BreakMode> mode;
  final Value<DateTime> startedAt;
  final Value<int> durationMs;
  final Value<double> earned;
  final Value<String?> businessName;
  final Value<BusinessCategory?> businessCategory;
  final Value<double?> damages;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.earned = const Value.absent(),
    this.businessName = const Value.absent(),
    this.businessCategory = const Value.absent(),
    this.damages = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required BreakMode mode,
    required DateTime startedAt,
    required int durationMs,
    required double earned,
    this.businessName = const Value.absent(),
    this.businessCategory = const Value.absent(),
    this.damages = const Value.absent(),
  }) : mode = Value(mode),
       startedAt = Value(startedAt),
       durationMs = Value(durationMs),
       earned = Value(earned);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? mode,
    Expression<DateTime>? startedAt,
    Expression<int>? durationMs,
    Expression<double>? earned,
    Expression<String>? businessName,
    Expression<String>? businessCategory,
    Expression<double>? damages,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (startedAt != null) 'started_at': startedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (earned != null) 'earned': earned,
      if (businessName != null) 'business_name': businessName,
      if (businessCategory != null) 'business_category': businessCategory,
      if (damages != null) 'damages': damages,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<BreakMode>? mode,
    Value<DateTime>? startedAt,
    Value<int>? durationMs,
    Value<double>? earned,
    Value<String?>? businessName,
    Value<BusinessCategory?>? businessCategory,
    Value<double?>? damages,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      durationMs: durationMs ?? this.durationMs,
      earned: earned ?? this.earned,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      damages: damages ?? this.damages,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $SessionsTable.$convertermode.toSql(mode.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (earned.present) {
      map['earned'] = Variable<double>(earned.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (businessCategory.present) {
      map['business_category'] = Variable<String>(
        $SessionsTable.$converterbusinessCategoryn.toSql(
          businessCategory.value,
        ),
      );
    }
    if (damages.present) {
      map['damages'] = Variable<double>(damages.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('earned: $earned, ')
          ..write('businessName: $businessName, ')
          ..write('businessCategory: $businessCategory, ')
          ..write('damages: $damages')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required BreakMode mode,
      required DateTime startedAt,
      required int durationMs,
      required double earned,
      Value<String?> businessName,
      Value<BusinessCategory?> businessCategory,
      Value<double?> damages,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<BreakMode> mode,
      Value<DateTime> startedAt,
      Value<int> durationMs,
      Value<double> earned,
      Value<String?> businessName,
      Value<BusinessCategory?> businessCategory,
      Value<double?> damages,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<BreakMode, BreakMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get earned => $composableBuilder(
    column: $table.earned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BusinessCategory?, BusinessCategory, String>
  get businessCategory => $composableBuilder(
    column: $table.businessCategory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get damages => $composableBuilder(
    column: $table.damages,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get earned => $composableBuilder(
    column: $table.earned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessCategory => $composableBuilder(
    column: $table.businessCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get damages => $composableBuilder(
    column: $table.damages,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BreakMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get earned =>
      $composableBuilder(column: $table.earned, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BusinessCategory?, String>
  get businessCategory => $composableBuilder(
    column: $table.businessCategory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get damages =>
      $composableBuilder(column: $table.damages, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<BreakMode> mode = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<double> earned = const Value.absent(),
                Value<String?> businessName = const Value.absent(),
                Value<BusinessCategory?> businessCategory =
                    const Value.absent(),
                Value<double?> damages = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                mode: mode,
                startedAt: startedAt,
                durationMs: durationMs,
                earned: earned,
                businessName: businessName,
                businessCategory: businessCategory,
                damages: damages,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required BreakMode mode,
                required DateTime startedAt,
                required int durationMs,
                required double earned,
                Value<String?> businessName = const Value.absent(),
                Value<BusinessCategory?> businessCategory =
                    const Value.absent(),
                Value<double?> damages = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                mode: mode,
                startedAt: startedAt,
                durationMs: durationMs,
                earned: earned,
                businessName: businessName,
                businessCategory: businessCategory,
                damages: damages,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, Session>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
