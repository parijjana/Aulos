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
  DateTimeColumn get lastCheck => dateTime().nullable()();
}

class RadioCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get stationCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [RadioStations, RadioCategories])
class RadioDatabase extends _$RadioDatabase {
  RadioDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Persistence Operations
  Future<void> upsertStations(List<RadioStationsCompanion> stations) async {
    await batch((b) {
      b.insertAll(radioStations, stations, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<RadioStation>> getByCategory(String tag, {int limit = 50, int offset = 0}) {
    return (select(radioStations)
          ..where((t) => t.tags.contains(tag))
          ..orderBy([(t) => OrderingTerm.desc(t.votes)])
          ..limit(limit, offset: offset))
        .get();
  }

  Stream<List<RadioStation>> watchByCategory(String tag, {int limit = 50}) {
    return (select(radioStations)
          ..where((t) => t.tags.contains(tag))
          ..orderBy([(t) => OrderingTerm.desc(t.votes)])
          ..limit(limit))
        .watch();
  }

  Future<List<RadioStation>> getTopStations({int limit = 50}) {
    return (select(radioStations)
          ..orderBy([(t) => OrderingTerm.desc(t.votes)])
          ..limit(limit))
        .get();
  }

  Stream<List<RadioStation>> watchTopStations({int limit = 50}) {
    return (select(radioStations)
          ..orderBy([(t) => OrderingTerm.desc(t.votes)])
          ..limit(limit))
        .watch();
  }

  Future<List<RadioStation>> getFavorites() {
    return (select(radioStations)..where((t) => t.isFavorite.equals(true))).get();
  }

  Future<void> setFavorite(String uuid, bool favorite) {
    return (update(radioStations)..where((t) => t.stationUuid.equals(uuid)))
        .write(RadioStationsCompanion(isFavorite: Value(favorite)));
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

  Future<List<RadioCategory>> getTopCategories() {
    return (select(radioCategories)
          ..orderBy([(t) => OrderingTerm.desc(t.stationCount)])
          ..limit(20))
        .get();
  }

  Future<void> upsertCategories(List<RadioCategoriesCompanion> categories) async {
    await batch((b) {
      b.insertAll(radioCategories, categories, mode: InsertMode.insertOrReplace);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'radio.sqlite'));
    return NativeDatabase(file);
  });
}
