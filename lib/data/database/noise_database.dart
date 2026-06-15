import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'noise_database.g.dart';

@DriftDatabase(tables: [SavedMixes])
class NoiseDatabase extends _$NoiseDatabase {
  NoiseDatabase() : super(_openConnection());
  NoiseDatabase.testing(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
      }
    },
  );

  // Saved Mixes (Ambient Mixer) CRUD
  Future<void> saveMix(SavedMixesCompanion companion) => into(savedMixes).insert(companion, mode: InsertMode.insertOrReplace);
  
  Future<List<SavedMix>> getAllMixes() => select(savedMixes).get();
  
  Future<void> deleteMix(String id) => (delete(savedMixes)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'noise_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
