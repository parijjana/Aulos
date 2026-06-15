import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/data/library/providers/audnexus_service.dart';
import 'package:aulos/domain/library/library_service.dart' as domain_lib;
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;

class MockLibraryService extends Mock implements domain_lib.LibraryService {}
class MockConnectionManager extends Mock implements ConnectionManager {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockAudnexusService extends Mock implements AudnexusService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audiobook Music Mixup Regression Tests', () {
    late AppDatabase appDb;
    late AudiobookDatabase audiobookDb;
    late PlaybackDatabase playbackDb;
    late PersistentLibraryServiceImpl libraryService;
    late MockLibraryService mockScanner;
    late MockConnectionManager mockConnectionManager;
    late MockSettingsViewModel mockSettingsVM;
    late MockAudnexusService mockAudnexus;
    late LibraryViewModel viewModel;

    setUp(() async {
      appDb = AppDatabase.testing(NativeDatabase.memory());
      audiobookDb = AudiobookDatabase.testing(NativeDatabase.memory());
      playbackDb = PlaybackDatabase.testing(NativeDatabase.memory());
      mockScanner = MockLibraryService();
      mockConnectionManager = MockConnectionManager();
      mockSettingsVM = MockSettingsViewModel();
      mockAudnexus = MockAudnexusService();

      libraryService = PersistentLibraryServiceImpl(
        db: appDb,
        audiobookDb: audiobookDb,
        scanner: mockScanner,
      );

      when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(false);
      when(() => mockSettingsVM.lastViewType).thenReturn(LibraryViewType.list);
      when(() => mockSettingsVM.libraryHubTabIndex).thenReturn(0);
      when(() => mockConnectionManager.remoteCommands).thenAnswer((_) => const Stream.empty());
      when(() => mockConnectionManager.isClient).thenReturn(false);
      when(() => mockConnectionManager.addListener(any())).thenReturn(null);
      when(() => mockConnectionManager.removeListener(any())).thenReturn(null);

      viewModel = LibraryViewModel(
        libraryService: libraryService,
        playbackDb: playbackDb,
        audnexus: mockAudnexus,
        connectionManager: mockConnectionManager,
        settingsVM: mockSettingsVM,
      );
    });

    tearDown(() async {
      await appDb.close();
      await audiobookDb.close();
      await playbackDb.close();
    });

    test('should load correct tracks when audiobook and music album have overlapping IDs', () async {
      // 1. Seed music album and track in appDb
      final artistId = await appDb.ensureArtist('Foxes');
      final albumId = await appDb.ensureAlbum('Youth - Single', artistId);

      await appDb.into(appDb.tracks).insert(
        TracksCompanion.insert(
          id: 'music_track_1',
          path: 'D:\\Music\\Youth - Single\\1-01 Youth.m4a',
          title: 'Youth',
          folderId: 'folder_1',
          artistId: Value(artistId),
          albumId: Value(albumId),
          durationSeconds: const Value(261),
          isAudiobook: const Value(false),
        ),
      );

      // 2. Seed audiobook and track in audiobookDb
      final bookArtistId = await audiobookDb.ensureArtist('Arthur Conan Doyle');
      final bookId = await audiobookDb.ensureAudiobook('A Selection of the Cases of Sherlock Holmes', bookArtistId);

      await audiobookDb.into(audiobookDb.audiobookTracks).insert(
        AudiobookTracksCompanion.insert(
          id: 'audiobook_track_1',
          path: 'D:\\Audiobooks\\Sherlock\\01.mp3',
          title: 'A Scandal in Bohemia',
          artistId: Value(bookArtistId),
          audiobookId: Value(bookId),
          durationSeconds: const Value(1200),
          isStream: const Value(false),
        ),
      );

      // 3. Test LibraryViewModel loads correct tracks when selecting the audiobook
      final audiobookAlbum = Album(
        id: bookId,
        name: 'A Selection of the Cases of Sherlock Holmes',
        artistId: bookArtistId,
        isAudiobook: true,
        isFavorite: false,
        playCount: 0,
        isPlayed: false,
        isDownloadedViaAulos: false,
      );

      await viewModel.selectItem(audiobookAlbum);

      // Verify the loaded tracks inside viewModel belong to the audiobook, not the music album
      expect(viewModel.tracks.length, equals(1));
      expect(viewModel.tracks.first.title, equals('A Scandal in Bohemia'));
      expect(viewModel.tracks.first.path, equals('D:\\Audiobooks\\Sherlock\\01.mp3'));
      expect(viewModel.tracks.first.isAudiobook, isTrue);

      // 4. Test LibraryViewModel loads correct tracks when selecting the music album
      final musicAlbum = Album(
        id: albumId,
        name: 'Youth - Single',
        artistId: artistId,
        isAudiobook: false,
        isFavorite: false,
        playCount: 0,
        isPlayed: false,
        isDownloadedViaAulos: false,
      );

      await viewModel.selectItem(musicAlbum);

      // Verify the loaded tracks inside viewModel belong to the music album
      expect(viewModel.tracks.length, equals(1));
      expect(viewModel.tracks.first.title, equals('Youth'));
      expect(viewModel.tracks.first.path, equals('D:\\Music\\Youth - Single\\1-01 Youth.m4a'));
      expect(viewModel.tracks.first.isAudiobook, isFalse);
    });

    test('enrichAudiobook should update AudiobookDatabase, NOT AppDatabase', () async {
      // Seed audiobook
      final bookArtistId = await audiobookDb.ensureArtist('Arthur Conan Doyle');
      final bookId = await audiobookDb.ensureAudiobook('A Selection of the Cases of Sherlock Holmes', bookArtistId);

      // Seed a track so there is one track
      await audiobookDb.into(audiobookDb.audiobookTracks).insert(
        AudiobookTracksCompanion.insert(
          id: 'audiobook_track_1',
          path: 'D:\\Audiobooks\\Sherlock\\01.mp3',
          title: 'A Scandal in Bohemia',
          artistId: Value(bookArtistId),
          audiobookId: Value(bookId),
          durationSeconds: const Value(1200),
          isStream: const Value(false),
        ),
      );

      // Seed music album/artist in appDb
      final musicArtistId = await appDb.ensureArtist('Foxes');
      final musicAlbumId = await appDb.ensureAlbum('Youth - Single', musicArtistId);

      final meta = {
        'asin': 'B000000000',
        'title': 'A Selection of the Cases of Sherlock Holmes',
        'description': 'Sherlock Holmes stories',
        'authors': ['Arthur Conan Doyle'],
        'narrators': ['John Smith'],
        'series': [
          {'name': 'Sherlock Holmes', 'position': '1'}
        ],
        'image': 'http://example.com/sherlock.jpg',
      };

      final authorMeta = {
        'description': 'Arthur Conan Doyle was a British writer.',
        'image': 'http://example.com/doyle.jpg',
      };

      when(() => mockAudnexus.getBookMetadata('B000000000')).thenAnswer((_) async => meta);
      when(() => mockAudnexus.getChapters('B000000000')).thenAnswer((_) async => [
        {'title': 'Chapter 1', 'startOffsetMs': 0, 'lengthMs': 1200000}
      ]);
      when(() => mockAudnexus.getAuthorMetadata('Arthur Conan Doyle')).thenAnswer((_) async => authorMeta);

      final bookAlbum = Album(
        id: bookId,
        name: 'A Selection of the Cases of Sherlock Holmes',
        artistId: bookArtistId,
        isAudiobook: true,
        asin: 'B000000000',
        isFavorite: false,
        playCount: 0,
        isPlayed: false,
        isDownloadedViaAulos: false,
      );

      await viewModel.enrichAudiobook(bookAlbum);

      // Verify AudiobookDatabase updated correctly
      final updatedBook = await (audiobookDb.select(audiobookDb.audiobooks)..where((a) => a.id.equals(bookId))).getSingle();
      expect(updatedBook.description, equals('Sherlock Holmes stories'));
      expect(updatedBook.seriesName, equals('Sherlock Holmes'));
      expect(updatedBook.seriesPosition, equals(1));
      expect(updatedBook.coverArtUrl, equals('http://example.com/sherlock.jpg'));

      final updatedArtist = await (audiobookDb.select(audiobookDb.audiobookArtists)..where((a) => a.id.equals(bookArtistId))).getSingle();
      expect(updatedArtist.bio, equals('Arthur Conan Doyle was a British writer.'));
      expect(updatedArtist.photoUrl, equals('http://example.com/doyle.jpg'));

      final chapters = await audiobookDb.getChaptersForTrack('audiobook_track_1');
      expect(chapters.length, equals(1));
      expect(chapters.first.title, equals('Chapter 1'));

      // Verify AppDatabase (music) was NOT touched
      final musicAlbum = await (appDb.select(appDb.albums)..where((a) => a.id.equals(musicAlbumId))).getSingle();
      expect(musicAlbum.description, isNull);
      expect(musicAlbum.coverArtUrl, isNull);

      final musicArtist = await (appDb.select(appDb.artists)..where((a) => a.id.equals(musicArtistId))).getSingle();
      expect(musicArtist.bio, isNull);
      expect(musicArtist.photoUrl, isNull);
    });
  });
}
