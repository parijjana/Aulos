import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/insights_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase db;
  late InsightsViewModel viewModel;

  setUp(() {
    db = AppDatabase.testing(NativeDatabase.memory());
    viewModel = InsightsViewModel(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Favorites streams should emit empty lists initially', () async {
    expect(await viewModel.favoriteTracks.first, isEmpty);
    expect(await viewModel.favoriteArtists.first, isEmpty);
    expect(await viewModel.favoriteAlbums.first, isEmpty);
  });

  test('toggleTrackFavorite should update the database', () async {
    // 1. Setup: Add a track
    await db.into(db.folders).insert(FoldersCompanion.insert(path: '/test', name: 'test'));
    final trackId = await db.into(db.tracks).insert(TracksCompanion.insert(
      path: 'test.mp3',
      title: 'Test Track',
      folderId: 1,
    ));

    final track = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
    
    // 2. Act: Toggle favorite
    await viewModel.toggleTrackFavorite(track);

    // 3. Assert
    final updatedTrack = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
    expect(updatedTrack.isFavorite, isTrue);
    expect(await viewModel.favoriteTracks.first, hasLength(1));
  });

  test('recordTrackPlay should increment play count', () async {
     await db.into(db.folders).insert(FoldersCompanion.insert(path: '/test', name: 'test'));
     final trackId = await db.into(db.tracks).insert(TracksCompanion.insert(
      path: 'test.mp3',
      title: 'Test Track',
      folderId: 1,
    ));

    await db.recordTrackPlay(trackId);
    
    final track = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
    expect(track.playCount, equals(1));
    expect(track.lastPlayed, isNotNull);
  });
}
