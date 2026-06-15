// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noise_database.dart';

// ignore_for_file: type=lint
class $SavedMixesTable extends SavedMixes
    with TableInfo<$SavedMixesTable, SavedMix> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedMixesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _mixDataMeta = const VerificationMeta(
    'mixData',
  );
  @override
  late final GeneratedColumn<String> mixData = GeneratedColumn<String>(
    'mix_data',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, mixData, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_mixes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedMix> instance, {
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
    if (data.containsKey('mix_data')) {
      context.handle(
        _mixDataMeta,
        mixData.isAcceptableOrUnknown(data['mix_data']!, _mixDataMeta),
      );
    } else if (isInserting) {
      context.missing(_mixDataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SavedMix map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedMix(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mixData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mix_data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavedMixesTable createAlias(String alias) {
    return $SavedMixesTable(attachedDatabase, alias);
  }
}

class SavedMix extends DataClass implements Insertable<SavedMix> {
  final String id;
  final String name;
  final String mixData;
  final DateTime createdAt;
  const SavedMix({
    required this.id,
    required this.name,
    required this.mixData,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['mix_data'] = Variable<String>(mixData);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedMixesCompanion toCompanion(bool nullToAbsent) {
    return SavedMixesCompanion(
      id: Value(id),
      name: Value(name),
      mixData: Value(mixData),
      createdAt: Value(createdAt),
    );
  }

  factory SavedMix.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedMix(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mixData: serializer.fromJson<String>(json['mixData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mixData': serializer.toJson<String>(mixData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedMix copyWith({
    String? id,
    String? name,
    String? mixData,
    DateTime? createdAt,
  }) => SavedMix(
    id: id ?? this.id,
    name: name ?? this.name,
    mixData: mixData ?? this.mixData,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedMix copyWithCompanion(SavedMixesCompanion data) {
    return SavedMix(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mixData: data.mixData.present ? data.mixData.value : this.mixData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedMix(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mixData: $mixData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, mixData, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMix &&
          other.id == this.id &&
          other.name == this.name &&
          other.mixData == this.mixData &&
          other.createdAt == this.createdAt);
}

class SavedMixesCompanion extends UpdateCompanion<SavedMix> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> mixData;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavedMixesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mixData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedMixesCompanion.insert({
    required String id,
    required String name,
    required String mixData,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       mixData = Value(mixData);
  static Insertable<SavedMix> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mixData,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mixData != null) 'mix_data': mixData,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedMixesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? mixData,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavedMixesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mixData: mixData ?? this.mixData,
      createdAt: createdAt ?? this.createdAt,
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
    if (mixData.present) {
      map['mix_data'] = Variable<String>(mixData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedMixesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mixData: $mixData, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$NoiseDatabase extends GeneratedDatabase {
  _$NoiseDatabase(QueryExecutor e) : super(e);
  $NoiseDatabaseManager get managers => $NoiseDatabaseManager(this);
  late final $SavedMixesTable savedMixes = $SavedMixesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedMixes];
}

typedef $$SavedMixesTableCreateCompanionBuilder =
    SavedMixesCompanion Function({
      required String id,
      required String name,
      required String mixData,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SavedMixesTableUpdateCompanionBuilder =
    SavedMixesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> mixData,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SavedMixesTableFilterComposer
    extends Composer<_$NoiseDatabase, $SavedMixesTable> {
  $$SavedMixesTableFilterComposer({
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

  ColumnFilters<String> get mixData => $composableBuilder(
    column: $table.mixData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedMixesTableOrderingComposer
    extends Composer<_$NoiseDatabase, $SavedMixesTable> {
  $$SavedMixesTableOrderingComposer({
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

  ColumnOrderings<String> get mixData => $composableBuilder(
    column: $table.mixData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedMixesTableAnnotationComposer
    extends Composer<_$NoiseDatabase, $SavedMixesTable> {
  $$SavedMixesTableAnnotationComposer({
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

  GeneratedColumn<String> get mixData =>
      $composableBuilder(column: $table.mixData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavedMixesTableTableManager
    extends
        RootTableManager<
          _$NoiseDatabase,
          $SavedMixesTable,
          SavedMix,
          $$SavedMixesTableFilterComposer,
          $$SavedMixesTableOrderingComposer,
          $$SavedMixesTableAnnotationComposer,
          $$SavedMixesTableCreateCompanionBuilder,
          $$SavedMixesTableUpdateCompanionBuilder,
          (
            SavedMix,
            BaseReferences<_$NoiseDatabase, $SavedMixesTable, SavedMix>,
          ),
          SavedMix,
          PrefetchHooks Function()
        > {
  $$SavedMixesTableTableManager(_$NoiseDatabase db, $SavedMixesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedMixesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedMixesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedMixesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mixData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedMixesCompanion(
                id: id,
                name: name,
                mixData: mixData,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String mixData,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedMixesCompanion.insert(
                id: id,
                name: name,
                mixData: mixData,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedMixesTableProcessedTableManager =
    ProcessedTableManager<
      _$NoiseDatabase,
      $SavedMixesTable,
      SavedMix,
      $$SavedMixesTableFilterComposer,
      $$SavedMixesTableOrderingComposer,
      $$SavedMixesTableAnnotationComposer,
      $$SavedMixesTableCreateCompanionBuilder,
      $$SavedMixesTableUpdateCompanionBuilder,
      (SavedMix, BaseReferences<_$NoiseDatabase, $SavedMixesTable, SavedMix>),
      SavedMix,
      PrefetchHooks Function()
    >;

class $NoiseDatabaseManager {
  final _$NoiseDatabase _db;
  $NoiseDatabaseManager(this._db);
  $$SavedMixesTableTableManager get savedMixes =>
      $$SavedMixesTableTableManager(_db, _db.savedMixes);
}
