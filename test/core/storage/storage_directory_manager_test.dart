import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aulos/core/storage/storage_directory_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late SharedPreferences prefs;
  late StorageDirectoryManager manager;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('aulos_storage_test');
    
    // Mock PathProvider
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory' ||
          methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    manager = StorageDirectoryManager(prefs);
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('default directory fallback', () async {
    final dir = await manager.getDatabaseDirectory();
    expect(dir.path, equals(tempDir.path));
  });

  test('custom directory configuration', () async {
    final customDir = Directory(p.join(tempDir.path, 'custom_db_dir'));
    await customDir.create(recursive: true);

    await manager.setCustomPath(customDir.path);
    final dir = await manager.getDatabaseDirectory();
    expect(dir.path, equals(customDir.path));
  });

  test('database file migration copies files', () async {
    // 1. Create a dummy sqlite file in current directory
    final currentDir = await manager.getDatabaseDirectory();
    final dummyDb = File(p.join(currentDir.path, 'localaudio.sqlite'));
    await dummyDb.writeAsString('sqlite-content');

    final dummyJournal = File(p.join(currentDir.path, 'localaudio.sqlite-journal'));
    await dummyJournal.writeAsString('sqlite-journal-content');

    // 2. Set custom path and migrate
    final targetDir = Directory(p.join(tempDir.path, 'target_db_dir'));
    await manager.migrateDatabases(targetDir.path);

    // 3. Verify copied
    final copiedDb = File(p.join(targetDir.path, 'localaudio.sqlite'));
    final copiedJournal = File(p.join(targetDir.path, 'localaudio.sqlite-journal'));

    expect(await copiedDb.exists(), isTrue);
    expect(await copiedDb.readAsString(), equals('sqlite-content'));

    expect(await copiedJournal.exists(), isTrue);
    expect(await copiedJournal.readAsString(), equals('sqlite-journal-content'));
  });
}
