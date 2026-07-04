import 'dart:async';
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
import 'package:drift/native.dart';

class MockPlaybackEngine extends Mock implements engine_domain.PlaybackEngine {}
class MockQueueViewModel extends Mock implements qvm.QueueViewModel {}
class MockConnectionManager extends Mock implements ConnectionManager {}
class MockRadioDatabase extends Mock implements RadioDatabase {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(engine_domain.RepeatMode.off);
    registerFallbackValue(
      Track(id: '0', path: '', title: '', artistId: '0', folderId: '0', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false),
    );
    registerFallbackValue(
      PlaybackTrack(id: '0', path: '', title: '', artistId: '0', folderId: '0', rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false),
    );
  });

  late PlayerViewModel viewModel;
  late MockPlaybackEngine mockEngine;
  late MockQueueViewModel mockQueueVM;
  late MockConnectionManager mockConnectionManager;
  late AppDatabase db;
  late RadioDatabase radioDb;
  late PlaybackDatabase playbackDb;
  late AudiobookDatabase audiobookDb;
  late PodcastDatabase podcastDb;
  late MockSettingsViewModel mockSettingsVM;

  late StreamController<engine_domain.PlaybackState> stateController;
  late StreamController<PlaybackTrack?> trackController;
  late StreamController<Duration> posController;
  late StreamController<Duration?> durController;

  setUp(() {
    mockEngine = MockPlaybackEngine();
    mockQueueVM = MockQueueViewModel();
    mockConnectionManager = MockConnectionManager();
    db = AppDatabase.testing(NativeDatabase.memory());
    radioDb = RadioDatabase.testing(NativeDatabase.memory());
    playbackDb = PlaybackDatabase.testing(NativeDatabase.memory());
    audiobookDb = AudiobookDatabase.testing(NativeDatabase.memory());
    podcastDb = PodcastDatabase.testing(NativeDatabase.memory());
    mockSettingsVM = MockSettingsViewModel();
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);
    when(() => mockSettingsVM.setLastMusicTrack(any())).thenAnswer((_) async {});
    when(() => mockSettingsVM.setLastAudiobookTrack(any())).thenAnswer((_) async {});
    when(() => mockSettingsVM.setLastNoiseTrack(any())).thenAnswer((_) async {});

    stateController = StreamController<engine_domain.PlaybackState>.broadcast();
    trackController = StreamController<PlaybackTrack?>.broadcast();
    posController = StreamController<Duration>.broadcast();
    durController = StreamController<Duration?>.broadcast();

    when(() => mockEngine.playbackStateStream).thenAnswer((_) => stateController.stream);
    when(() => mockEngine.positionStream).thenAnswer((_) => posController.stream);
    when(() => mockEngine.durationStream).thenAnswer((_) => durController.stream);
    when(() => mockEngine.currentTrackStream).thenAnswer((_) => trackController.stream);
    when(() => mockEngine.externalCommandStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.icyMetadataStream).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.setVolume(any())).thenAnswer((_) async => {});
    when(() => mockEngine.play()).thenAnswer((_) async => {});
    when(() => mockEngine.pause()).thenAnswer((_) async => {});
    when(() => mockEngine.stop()).thenAnswer((_) async => {});
    when(() => mockEngine.loadTrack(any())).thenAnswer((_) async => {});

    when(() => mockQueueVM.addListener(any())).thenReturn(null);
    when(() => mockQueueVM.removeListener(any())).thenReturn(null);
    when(() => mockQueueVM.currentTrack).thenReturn(null);
    when(() => mockQueueVM.currentQueue).thenReturn([]);
    when(() => mockQueueVM.repeatMode).thenReturn(engine_domain.RepeatMode.off);

    when(() => mockConnectionManager.remoteCommands).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectionManager.isHost).thenReturn(false);
    when(() => mockConnectionManager.isClient).thenReturn(false);

    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(false);
    when(() => mockSettingsVM.setLastRadioStation(any())).thenAnswer((_) async => {});
    when(() => mockSettingsVM.setLastPodcastEpisode(any())).thenAnswer((_) async => {});

    viewModel = PlayerViewModel(
      engine: mockEngine,
      queueVM: mockQueueVM,
      connectionManager: mockConnectionManager,
      db: db,
      radioDb: radioDb,
      playbackDb: playbackDb,
      audiobookDb: audiobookDb,
      podcastDb: podcastDb,
      settingsVM: mockSettingsVM,
    );
  });

  tearDown(() async {
    await stateController.close();
    await trackController.close();
    await posController.close();
    await durController.close();
    await db.close();
    await radioDb.close();
    await playbackDb.close();
    await audiobookDb.close();
    await podcastDb.close();
  });

  group('Playback Media Type Regression Tests', () {
    test('playing a radio station should NOT trigger skipNext from previous podcast completed state', () async {
      // 1. Initial State: Podcast is loaded
      final podcastTrack = Track(
        id: 'podcast_5', // negative id is podcast
        path: 'podcast.mp3',
        title: 'Podcast Episode',
        artistId: null,
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );

      // Setup queue VM
      when(() => mockQueueVM.currentTrack).thenReturn(podcastTrack);
      when(() => mockQueueVM.skipNext()).thenReturn(null);

      // Load podcast track initially (with fast stop)
      when(() => mockEngine.stop()).thenAnswer((_) async {});
      await viewModel.loadTrack(podcastTrack);
      trackController.add(podcastTrack.toDomain());
      stateController.add(engine_domain.PlaybackState.playing);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.currentMediaType, MediaType.podcast);
      expect(viewModel.isPlaying, isTrue);

      // Mock stop to take 1100ms to simulate network buffering/delayed stop during transition
      when(() => mockEngine.stop()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      });

      // 2. User plays a radio station
      final radioTrack = Track(
        id: 'radio_0', // 0 is radio
        path: 'http://radio.stream',
        title: 'Radio Station',
        artistId: null,
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );

      // Simulate loadTrack for Radio station
      final futureLoad = viewModel.loadTrack(radioTrack, description: 'station-uuid|description');
      
      // Delay so that the debounce window (1 second) expires
      await Future<void>.delayed(const Duration(milliseconds: 1050));

      // Engine finishes stopping/completes
      stateController.add(engine_domain.PlaybackState.completed);
      await Future<void>.delayed(Duration.zero);

      await futureLoad;

      // Verify that skipNext was NOT called on queue VM
      verifyNever(() => mockQueueVM.skipNext());
    });

    test('music play/pause should correctly delegate to engine', () async {
      final musicTrack = Track(
        id: 'music_10', // positive id is music
        path: 'music.mp3',
        title: 'Music Track',
        artistId: null,
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );

      await viewModel.loadTrack(musicTrack);
      trackController.add(musicTrack.toDomain());
      stateController.add(engine_domain.PlaybackState.playing);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.currentMediaType, MediaType.music);
      expect(viewModel.isPlaying, isTrue);

      // Clear earlier play() calls from loadTrack
      clearInteractions(mockEngine);

      // Pause music
      viewModel.pause();
      verify(() => mockEngine.pause()).called(1);

      // Play music
      viewModel.play();
      verify(() => mockEngine.play()).called(1);
    });

    test('_activeMediaType persists across loadTrack lifecycle', () async {
      final podcastTrack = Track(
        id: 'podcast_5',
        path: 'podcast.mp3',
        title: 'Podcast',
        artistId: null,
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );

      expect(viewModel.currentMediaType, MediaType.music); // default

      // Start loading podcast
      final futureLoad = viewModel.loadTrack(podcastTrack);
      
      // During load, currentMediaType should be podcast, not music
      expect(viewModel.currentMediaType, MediaType.podcast); 

      await futureLoad;
      expect(viewModel.currentMediaType, MediaType.podcast);
    });
  });
}
