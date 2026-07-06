import 'dart:async';
import 'dart:typed_data';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart' as qvm;
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as engine_domain;
import 'package:aulos/domain/playback/playback_track.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:drift/native.dart';

class MockPlaybackEngine extends Mock implements engine_domain.PlaybackEngine {}
class MockQueueViewModel extends Mock implements qvm.QueueViewModel {}
class MockConnectionManager extends Mock implements ConnectionManager {}
class MockRadioDatabase extends Mock implements RadioDatabase {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(engine_domain.RepeatMode.off);
    registerFallbackValue(
      Track(id: '0', path: '', title: '', artistId: '0', folderId: '0', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false),
    );
    registerFallbackValue(
      PlaybackTrack(id: '0', path: '', title: '', artistId: '0', folderId: '0', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false),
    );
    registerFallbackValue(const BookmarksCompanion());
  });

  late PlayerViewModel viewModel;
  late MockPlaybackEngine mockEngine;
  late MockQueueViewModel mockQueueVM;
  late MockConnectionManager mockConnectionManager;
  late AppDatabase db;
  late MockRadioDatabase mockRadioDb;
  late PlaybackDatabase playbackDb;
  late AudiobookDatabase audiobookDb;
  late PodcastDatabase podcastDb;
  late MockSettingsViewModel mockSettingsVM;

  setUp(() {
    mockEngine = MockPlaybackEngine();
    mockQueueVM = MockQueueViewModel();
    mockConnectionManager = MockConnectionManager();
    db = AppDatabase.testing(NativeDatabase.memory());
    mockRadioDb = MockRadioDatabase();
    playbackDb = PlaybackDatabase.testing(NativeDatabase.memory());
    audiobookDb = AudiobookDatabase.testing(NativeDatabase.memory());
    podcastDb = PodcastDatabase.testing(NativeDatabase.memory());
    mockSettingsVM = MockSettingsViewModel();
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);
    when(() => mockSettingsVM.setLastMusicTrack(any())).thenAnswer((_) async {});
    when(() => mockSettingsVM.setLastAudiobookTrack(any())).thenAnswer((_) async {});
    when(() => mockSettingsVM.setLastNoiseTrack(any())).thenAnswer((_) async {});
    when(() => mockSettingsVM.setLastPodcastEpisode(any())).thenAnswer((_) async {});
    when(() => mockSettingsVM.setLastRadioStation(any())).thenAnswer((_) async {});

    when(() => mockEngine.playbackStateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.positionStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.durationStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.currentTrackStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.externalCommandStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.icyMetadataStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.setVolume(any())).thenAnswer((_) async => {});
    
    when(() => mockQueueVM.addListener(any())).thenReturn(null);
    when(() => mockQueueVM.removeListener(any())).thenReturn(null);
    when(() => mockQueueVM.currentTrack).thenReturn(null);
    when(() => mockQueueVM.currentQueue).thenReturn([]);
    when(() => mockQueueVM.repeatMode).thenReturn(engine_domain.RepeatMode.off);
    when(() => mockQueueVM.getArtistName(any())).thenAnswer((_) async => 'Unknown Artist');
    when(() => mockQueueVM.getAlbumName(any())).thenAnswer((_) async => 'Unknown Album');
    
    when(() => mockConnectionManager.remoteCommands).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectionManager.isHost).thenReturn(false);
    when(() => mockConnectionManager.isClient).thenReturn(false);

    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);

    viewModel = PlayerViewModel(
      engine: mockEngine,
      queueVM: mockQueueVM,
      connectionManager: mockConnectionManager,
      db: db,
      radioDb: mockRadioDb,
      playbackDb: playbackDb,
      audiobookDb: audiobookDb,
      podcastDb: podcastDb,
      settingsVM: mockSettingsVM,
      logService: NoOpLogService(),
    );
  });

  tearDown(() async {
    await db.close();
    await playbackDb.close();
    await audiobookDb.close();
    await podcastDb.close();
  });

  group('PlayerViewModel', () {
    test('play() should call engine.play()', () async {
      when(() => mockEngine.play()).thenAnswer((_) async => {});
      viewModel.play();
      verify(() => mockEngine.play()).called(1);
    });

    test('pause() should call engine.pause()', () async {
      when(() => mockEngine.pause()).thenAnswer((_) async => {});
      viewModel.pause();
      verify(() => mockEngine.pause()).called(1);
    });

    test('should update state when engine state changes', () async {
      final stateController = StreamController<engine_domain.PlaybackState>();
      when(() => mockEngine.playbackStateStream).thenAnswer((_) => stateController.stream);

      // Re-init to use the stream
      viewModel = PlayerViewModel(
        engine: mockEngine,
        queueVM: mockQueueVM,
        connectionManager: mockConnectionManager,
        db: db,
        radioDb: mockRadioDb,
        playbackDb: playbackDb,
        audiobookDb: audiobookDb,
        podcastDb: podcastDb,
        settingsVM: mockSettingsVM,
        logService: NoOpLogService(),
      );

      stateController.add(engine_domain.PlaybackState.playing);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.isPlaying, isTrue);

      stateController.add(engine_domain.PlaybackState.paused);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.isPlaying, isFalse);
    });

    test('bookmark() should save current position to database', () async {
      // Set artistId to null so it doesn't try to query Mock/real artists table which has no rows
      final track = Track(id: '1', path: 'test.mp3', title: 'Test', artistId: null, folderId: '1', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false);
      when(() => mockEngine.currentTrackStream).thenAnswer((_) => Stream.value(track.toDomain()));
      when(() => mockEngine.loadTrack(any())).thenAnswer((_) async => {});
      when(() => mockEngine.play()).thenAnswer((_) async => {});
      
      // Re-init with track
      viewModel = PlayerViewModel(
        engine: mockEngine,
        queueVM: mockQueueVM,
        connectionManager: mockConnectionManager,
        db: db,
        radioDb: mockRadioDb,
        playbackDb: playbackDb,
        audiobookDb: audiobookDb,
        podcastDb: podcastDb,
        settingsVM: mockSettingsVM,
        logService: NoOpLogService(),
      );
      
      await viewModel.loadTrack(track);
      viewModel.setBookmarkRange(0, 10000);
      await viewModel.saveBookmark(title: 'Test');
      
      final bookmarks = await playbackDb.select(playbackDb.bookmarks).get();
      expect(bookmarks.length, 1);
    });

    test('startSleepTimer should activate timer, notify, and cancelTimer should deactivate', () async {
      expect(viewModel.isSleepTimerActive, isFalse);
      expect(viewModel.sleepTimeRemaining, Duration.zero);

      viewModel.startSleepTimer(const Duration(minutes: 10));
      expect(viewModel.isSleepTimerActive, isTrue);
      expect(viewModel.sleepTimeRemaining.inMinutes, closeTo(10, 1));

      viewModel.cancelSleepTimer();
      expect(viewModel.isSleepTimerActive, isFalse);
      expect(viewModel.sleepTimeRemaining, Duration.zero);
    });

    test('loadTrack resolves missing cover art from album', () async {
      const artistId = 'artist_1';
      await db.into(db.artists).insert(
        ArtistsCompanion.insert(id: artistId, name: 'Test Artist'),
      );
      const albumId = 'album_1';
      await db.into(db.albums).insert(
        AlbumsCompanion.insert(
          id: albumId,
          name: 'Test Album',
          artistId: const Value(artistId),
          coverArt: Value(Uint8List.fromList([1, 2, 3])),
        ),
      );

      final track = Track(
        id: '2',
        path: 'test.mp3',
        title: 'Test Track',
        artistId: artistId,
        albumId: albumId,
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
        coverArt: null,
      );
      PlaybackTrack? capturedTrack;
      when(() => mockEngine.stop()).thenAnswer((_) async {});
      when(() => mockEngine.loadTrack(any())).thenAnswer((invocation) async {
        capturedTrack = invocation.positionalArguments[0] as PlaybackTrack;
      });
      when(() => mockEngine.play()).thenAnswer((_) async {});

      await viewModel.loadTrack(track);

      expect(capturedTrack, isNotNull);
      expect(capturedTrack!.coverArt, isNotNull);
      expect(capturedTrack!.coverArt, Uint8List.fromList([1, 2, 3]));
      expect(viewModel.currentAlbumName, 'Test Album');
    });

    test('skipNext and skipPrevious should do nothing if currentMediaType is radio', () async {
      final radioTrack = Track(id: 'radio_1', path: 'radio.mp3', title: 'Radio Station', artistId: null, folderId: '1', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false);
      when(() => mockEngine.stop()).thenAnswer((_) async {});
      when(() => mockEngine.loadTrack(any())).thenAnswer((_) async {});
      when(() => mockEngine.play()).thenAnswer((_) async {});

      await viewModel.loadTrack(radioTrack);

      viewModel.skipNext();
      verifyNever(() => mockQueueVM.skipNext());

      viewModel.skipPrevious();
      verifyNever(() => mockQueueVM.skipPrevious());
    });

    test('skipNext loads next track with autoplay false if media types differ', () async {
      final currentTrack = Track(id: 'podcast_1', path: 'pod.mp3', title: 'Podcast Episode', artistId: null, folderId: '1', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false);
      final nextTrack = Track(id: 'music_1', path: 'song.mp3', title: 'Music Track', artistId: null, folderId: '1', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false);

      when(() => mockQueueVM.currentTrack).thenReturn(currentTrack);
      when(() => mockEngine.stop()).thenAnswer((_) async {});
      when(() => mockEngine.loadTrack(any())).thenAnswer((_) async {});
      when(() => mockEngine.play()).thenAnswer((_) async {});
      when(() => mockEngine.pause()).thenAnswer((_) async {});

      // Load initial track
      await viewModel.loadTrack(currentTrack);

      // Now stub queue VM to return nextTrack as the current track after skipNext is called
      when(() => mockQueueVM.skipNext()).thenAnswer((_) {
        when(() => mockQueueVM.currentTrack).thenReturn(nextTrack);
      });

      // Wait for skip throttle to pass
      await Future<void>.delayed(const Duration(milliseconds: 510));

      // Call skipNext
      viewModel.skipNext();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Verify skipNext called and loaded nextTrack unscheduled/paused
      verify(() => mockQueueVM.skipNext()).called(1);
      verify(() => mockEngine.pause()).called(1);
    });

    test('skipNext loads next track with autoplay true if media types are the same', () async {
      final currentTrack = Track(id: 'music_1', path: 'song1.mp3', title: 'Music Track 1', artistId: null, folderId: '1', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false);
      final nextTrack = Track(id: 'music_2', path: 'song2.mp3', title: 'Music Track 2', artistId: null, folderId: '1', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false);

      when(() => mockQueueVM.currentTrack).thenReturn(currentTrack);
      when(() => mockEngine.stop()).thenAnswer((_) async {});
      when(() => mockEngine.loadTrack(any())).thenAnswer((_) async {});
      when(() => mockEngine.play()).thenAnswer((_) async {});

      // Load initial track
      await viewModel.loadTrack(currentTrack);

      // Now stub queue VM to return nextTrack as the current track after skipNext is called
      when(() => mockQueueVM.skipNext()).thenAnswer((_) {
        when(() => mockQueueVM.currentTrack).thenReturn(nextTrack);
      });

      // Wait for skip throttle to pass
      await Future<void>.delayed(const Duration(milliseconds: 510));

      // Call skipNext
      viewModel.skipNext();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Verify skipNext called and loaded nextTrack with play() triggered
      verify(() => mockQueueVM.skipNext()).called(1);
      verify(() => mockEngine.play()).called(2); // 1 for initial load, 1 for next track
    });
  });
}
