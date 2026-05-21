import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart'
    as qvm;
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as engine_domain;
import 'package:localaudioplayer/data/database/app_database.dart';

import 'package:localaudioplayer/domain/network/connection_manager.dart';

class MockPlaybackEngine extends Mock implements engine_domain.PlaybackEngine {}

class MockQueueViewModel extends Mock implements qvm.QueueViewModel {}

class MockConnectionManager extends Mock implements ConnectionManager {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  setUpAll(() {
    registerFallbackValue(engine_domain.RepeatMode.off);
    registerFallbackValue(
      Track(id: 0, path: '', title: '', artistId: 0, folderId: 0, rating: 0, isFavorite: false, playCount: 0),
    );
    registerFallbackValue(const BookmarksCompanion());
  });

  late PlayerViewModel viewModel;
  late MockPlaybackEngine mockEngine;
  late MockQueueViewModel mockQueueVM;
  late MockConnectionManager mockConnectionManager;
  late MockAppDatabase mockDb;

  setUp(() {
    mockEngine = MockPlaybackEngine();
    mockQueueVM = MockQueueViewModel();
    mockConnectionManager = MockConnectionManager();
    mockDb = MockAppDatabase();

    when(
      () => mockEngine.playbackStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockEngine.positionStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockEngine.durationStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockEngine.currentTrackStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockEngine.externalCommandStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockEngine.icyMetadataStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockEngine.setVolume(any())).thenAnswer((_) async => {});
    when(
      () => mockEngine.setMetadata(
        any(),
        any(),
        album: any(named: 'album'),
        art: any(named: 'art'),
      ),
    ).thenAnswer((_) async => {});
    when(() => mockQueueVM.addListener(any())).thenReturn(null);
    when(() => mockQueueVM.removeListener(any())).thenReturn(null);
    when(() => mockQueueVM.currentTrack).thenReturn(null);
    when(() => mockQueueVM.currentQueue).thenReturn([]);
    when(() => mockQueueVM.repeatMode).thenReturn(engine_domain.RepeatMode.off);
    when(
      () => mockQueueVM.getArtistName(any()),
    ).thenAnswer((_) async => 'Unknown Artist');
    when(
      () => mockQueueVM.getAlbumName(any()),
    ).thenAnswer((_) async => 'Unknown Album');
    when(
      () => mockConnectionManager.remoteCommands,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectionManager.isHost).thenReturn(false);
    when(() => mockConnectionManager.isClient).thenReturn(false);

    viewModel = PlayerViewModel(
      engine: mockEngine,
      queueVM: mockQueueVM,
      connectionManager: mockConnectionManager,
      db: mockDb,
    );
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
      when(
        () => mockEngine.playbackStateStream,
      ).thenAnswer((_) => stateController.stream);

      // Re-init to use the stream
      viewModel = PlayerViewModel(
        engine: mockEngine,
        queueVM: mockQueueVM,
        connectionManager: mockConnectionManager,
        db: mockDb,
      );

      stateController.add(engine_domain.PlaybackState.playing);
      await Future.delayed(Duration.zero);
      expect(viewModel.isPlaying, isTrue);

      stateController.add(engine_domain.PlaybackState.paused);
      await Future.delayed(Duration.zero);
      expect(viewModel.isPlaying, isFalse);
    });

    test('bookmark() should save current position to database', () async {
      final track = Track(id: 1, path: 'test.mp3', title: 'Test', artistId: 1, folderId: 1, rating: 0, isFavorite: false, playCount: 0);
      when(() => mockEngine.currentTrackStream).thenAnswer((_) => Stream.value(track));
      when(() => mockEngine.loadTrack(any())).thenAnswer((_) async => {});
      when(() => mockEngine.play()).thenAnswer((_) async => {});
      when(() => mockDb.saveBookmark(any())).thenAnswer((_) async => 1);
      
      // Re-init with track
      viewModel = PlayerViewModel(
        engine: mockEngine,
        queueVM: mockQueueVM,
        connectionManager: mockConnectionManager,
        db: mockDb,
      );
      
      await viewModel.loadTrack(track);
      await viewModel.bookmark();
      
      verify(() => mockDb.saveBookmark(any())).called(1);
    });
  });
}
