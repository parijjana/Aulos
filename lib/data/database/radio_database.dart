import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'radio_database.g.dart';

class RadioStations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stationUuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get homepage => text().nullable()();
  TextColumn get favicon => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get language => text().nullable()();
  IntColumn get votes => integer().withDefault(const Constant(0))();
  IntColumn get bitrate => integer().withDefault(const Constant(0))();
  TextColumn get codec => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastCheck => dateTime().nullable()();
}

class RadioCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get stationCount => integer().withDefault(const Constant(0))();
}

class RadioListeningStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stationUuid => text().unique()();
  IntColumn get timeSpentSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastListened => dateTime().nullable()();
}

@DriftDatabase(tables: [RadioStations, RadioCategories, RadioListeningStats])
class RadioDatabase extends _$RadioDatabase {
  RadioDatabase([String? basePath]) : super(_openConnection(basePath));
  RadioDatabase.testing(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 4;

  Future<void> _safeAddColumn(Migrator m, TableInfo table, GeneratedColumn column) async {
    try {
      await m.addColumn(table, column);
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('duplicate column name') || 
          err.contains('already exists') || 
          err.contains('sqlite_error')) {
        // Ignored duplicate column
        return;
      }
      rethrow;
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _safeAddColumn(m, radioStations, radioStations.isPinned);
      }
      if (from < 3) {
        await _safeAddColumn(m, radioStations, radioStations.isHidden);
        await _safeAddColumn(m, radioStations, radioStations.isAvailable);
      }
      if (from < 4) {
        await m.createTable(radioListeningStats);
      }
    },
  );

  Future<void> recordRadioListen(String uuid, int seconds) async {
    final existing = await (select(radioListeningStats)
          ..where((t) => t.stationUuid.equals(uuid)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(radioListeningStats)..where((t) => t.stationUuid.equals(uuid))).write(
        RadioListeningStatsCompanion(
          timeSpentSeconds: Value(existing.timeSpentSeconds + seconds),
          lastListened: Value(DateTime.now()),
        ),
      );
    } else {
      await into(radioListeningStats).insert(
        RadioListeningStatsCompanion.insert(
          stationUuid: uuid,
          timeSpentSeconds: Value(seconds),
          lastListened: Value(DateTime.now()),
        ),
      );
    }
  }

  Stream<List<RadioListeningStat>> watchRadioStats({int limit = 10}) =>
      (select(radioListeningStats)
            ..where((t) => t.timeSpentSeconds.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.timeSpentSeconds)])
            ..limit(limit))
          .watch();


  // Persistence Operations
  Future<void> upsertStations(List<RadioStationsCompanion> stations) async {
    await batch((b) {
      b.insertAll(radioStations, stations, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<RadioStation>> getByCategory(String tag, {int limit = 50, int offset = 0}) {
    return (select(radioStations)
          ..where((t) => t.tags.contains(tag) & t.isHidden.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.votes)])
          ..limit(limit, offset: offset))
        .get();
  }

  Stream<List<RadioStation>> watchByCategory(String tag, {int limit = 50}) {
    return (select(radioStations)
          ..where((t) => t.tags.contains(tag) & t.isHidden.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.votes)])
          ..limit(limit))
        .watch();
  }

  Future<List<RadioStation>> getTopStations({int limit = 50}) {
    return (select(radioStations)
          ..where((t) => t.isHidden.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.votes)])
          ..limit(limit))
        .get();
  }

  Stream<List<RadioStation>> watchTopStations({int limit = 50}) {
    return (select(radioStations)
          ..where((t) => t.isHidden.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.votes)])
          ..limit(limit))
        .watch();
  }

  Future<List<RadioStation>> getFavorites({bool includeHidden = false}) {
    final query = select(radioStations)..where((t) => t.isFavorite.equals(true));
    if (!includeHidden) {
      query.where((t) => t.isHidden.equals(false));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.name)]))
        .get();
  }

  Stream<List<RadioStation>> watchFavorites({bool includeHidden = false}) {
    final query = select(radioStations)..where((t) => t.isFavorite.equals(true));
    if (!includeHidden) {
      query.where((t) => t.isHidden.equals(false));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.name)]))
        .watch();
  }

  Future<void> setFavorite(String uuid, bool favorite) {
    return (update(radioStations)..where((t) => t.stationUuid.equals(uuid)))
        .write(RadioStationsCompanion(isFavorite: Value(favorite)));
  }

  Future<void> setPinned(String uuid, bool pinned) {
    return (update(radioStations)..where((t) => t.stationUuid.equals(uuid)))
        .write(RadioStationsCompanion(isPinned: Value(pinned)));
  }

  Future<List<RadioCategory>> getAllCategories() {
    return (select(radioCategories)
          ..orderBy([(t) => OrderingTerm.desc(t.stationCount), (t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<RadioCategory>> watchAllCategories() {
    return (select(radioCategories)
          ..orderBy([(t) => OrderingTerm.desc(t.stationCount), (t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<void> upsertCategories(List<RadioCategoriesCompanion> cats) async {
    await batch((b) {
      b.insertAll(radioCategories, cats, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<String>> getTopCountries() async {
    final query = selectOnly(radioStations, distinct: true)
      ..addColumns([radioStations.country])
      ..where(radioStations.country.isNotNull() & radioStations.country.isNotValue(''))
      ..groupBy([radioStations.country])
      ..orderBy([OrderingTerm.desc(radioStations.votes.count())]);
    
    final results = await query.map((row) => row.read(radioStations.country)).get();
    return results.whereType<String>().toList();
  }

  Future<List<String>> getTopLanguages() async {
    final query = selectOnly(radioStations, distinct: true)
      ..addColumns([radioStations.language])
      ..where(radioStations.language.isNotNull() & radioStations.language.isNotValue(''))
      ..groupBy([radioStations.language])
      ..orderBy([OrderingTerm.desc(radioStations.votes.count())]);
    
    final results = await query.map((row) => row.read(radioStations.language)).get();
    return results.whereType<String>().toList();
  }

  Future<List<RadioStation>> search(String query) {
    return (select(radioStations)
          ..where((t) => t.name.contains(query) | t.tags.contains(query))
          ..orderBy([(t) => OrderingTerm.desc(t.votes)])
          ..limit(100))
        .get();
  }

  Stream<List<RadioStation>> watchSearch(String query) {
    return (select(radioStations)
          ..where((t) => t.name.contains(query) | t.tags.contains(query))
          ..orderBy([(t) => OrderingTerm.desc(t.votes)])
          ..limit(100))
        .watch();
  }

  Future<void> setHidden(String uuid, bool hidden) {
    return (update(radioStations)..where((t) => t.stationUuid.equals(uuid)))
        .write(RadioStationsCompanion(isHidden: Value(hidden)));
  }

  Future<void> updateHealth(String uuid, bool available) {
    return (update(radioStations)..where((t) => t.stationUuid.equals(uuid)))
        .write(RadioStationsCompanion(
          isAvailable: Value(available),
          lastCheck: Value(DateTime.now()),
        ));
  }

  Future<void> deleteStation(String uuid) {
    return (delete(radioStations)..where((t) => t.stationUuid.equals(uuid))).go();
  }

  Future<void> clearCache() async {
    // Delete all categories
    await delete(radioCategories).go();
    // Delete all stations EXCEPT favorites
    await (delete(radioStations)..where((t) => t.isFavorite.equals(false))).go();
  }
}

LazyDatabase _openConnection(String? basePath) {
  return LazyDatabase(() async {
    final path = basePath ?? (await getApplicationDocumentsDirectory()).path;
    final file = File(p.join(path, 'radio.sqlite'));
    return NativeDatabase(file);
  });
}
