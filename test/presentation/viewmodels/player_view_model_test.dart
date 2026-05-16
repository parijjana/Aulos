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

void main() {
  setUpAll(() {
    registerFallbackValue(engine_domain.RepeatMode.off);
    registerFallbackValue(
      Track(id: 0, path: '', title: '', artistId: 0, folderId: 0, rating: 0),
    );
  });

  late PlayerViewModel viewModel;
  late MockPlaybackEngine mockEngine;
  late MockQueueViewModel mockQueueVM;
  late MockConnectionManager mockConnectionManager;

  setUp(() {
    mockEngine = MockPlaybackEngine();
    mockQueueVM = MockQueueViewModel();
    mockConnectionManager = MockConnectionManager();

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

      // Re-init with controller
      viewModel = PlayerViewModel(
        engine: mockEngine,
        queueVM: mockQueueVM,
        connectionManager: mockConnectionManager,
      );

      stateController.add(engine_domain.PlaybackState.playing);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state, engine_domain.PlaybackState.playing);

      stateController.add(engine_domain.PlaybackState.paused);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state, engine_domain.PlaybackState.paused);

      await stateController.close();
    });

    test('should auto-skip when track completes', () async {
      final stateController = StreamController<engine_domain.PlaybackState>();
      when(
        () => mockEngine.playbackStateStream,
      ).thenAnswer((_) => stateController.stream);
      when(() => mockQueueVM.skipNext()).thenReturn(null);
      when(() => mockQueueVM.currentTrack).thenReturn(null);
      when(() => mockQueueVM.repeatMode).thenReturn(engine_domain.RepeatMode.off);

      viewModel = PlayerViewModel(
        engine: mockEngine,
        queueVM: mockQueueVM,
        connectionManager: mockConnectionManager,
      );

      stateController.add(engine_domain.PlaybackState.completed);
      await Future<void>.delayed(Duration.zero);

      verify(() => mockQueueVM.skipNext()).called(1);
      await stateController.close();
    });
  });

  group('PlayerViewModel - Shuffling & Repeat', () {
    test('toggleShuffle should call queueVM.setShuffle', () {
      when(() => mockQueueVM.setShuffle(any())).thenReturn(null);
      viewModel.toggleShuffle();
      verify(() => mockQueueVM.setShuffle(true)).called(1);
    });

    test('toggleRepeat should call engine.setRepeatMode', () {
      when(() => mockEngine.setRepeatMode(any())).thenReturn(null);
      when(() => mockQueueVM.toggleRepeat()).thenReturn(null);
      when(() => mockQueueVM.repeatMode).thenReturn(engine_domain.RepeatMode.one);
      
      viewModel.toggleRepeat();
      verify(() => mockEngine.setRepeatMode(engine_domain.RepeatMode.one)).called(1);
    });
  });

  group('PlayerViewModel - External Commands', () {
    test(
      'should skip next when engine emits external skipNext command',
      () async {
        final commandController = StreamController<String>.broadcast();
        when(
          () => mockEngine.externalCommandStream,
        ).thenAnswer((_) => commandController.stream);
        when(() => mockQueueVM.skipNext()).thenReturn(null);
        when(() => mockQueueVM.currentTrack).thenReturn(null);

        viewModel = PlayerViewModel(
          engine: mockEngine,
          queueVM: mockQueueVM,
          connectionManager: mockConnectionManager,
        );

        commandController.add('skipNext');
        
        await Future<void>.delayed(const Duration(milliseconds: 100));

        verify(() => mockQueueVM.skipNext()).called(1);
        await commandController.close();
      },
    );
  });

  group('PlayerViewModel - Index-based playback', () {
    test('playTrackAtIndex should update index and load track', () async {
      final track = Track(
        id: 1,
        path: 'path',
        title: 'title',
        folderId: 1,
        artistId: 1,
        rating: 0,
      );
      when(() => mockQueueVM.currentQueue).thenReturn(List.filled(10, track));
      when(() => mockQueueVM.setTrackByIndex(any())).thenReturn(null);
      when(() => mockQueueVM.currentTrack).thenReturn(track);
      when(() => mockEngine.loadTrack(any())).thenAnswer((_) async => {});
      when(() => mockEngine.play()).thenAnswer((_) async => {});

      viewModel.playTrackAtIndex(5);

      verify(() => mockQueueVM.setTrackByIndex(5)).called(1);
      verify(() => mockEngine.loadTrack(track)).called(1);
    });
  });
}
