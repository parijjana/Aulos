import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:localaudioplayer/domain/network/connection_manager.dart';
import 'package:localaudioplayer/domain/network/socket_service.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as engine_domain;
import 'dart:async';

class QueueViewModel extends ChangeNotifier {
  final PersistentLibraryService _libraryService;
  final ConnectionManager? _connectionManager;

  List<Track> _queue = [];
  List<Track> _shuffledQueue = [];
  final List<Track> _history = [];
  int _currentIndex = -1;

  bool _isShuffle = false;
  engine_domain.RepeatMode _repeatMode = engine_domain.RepeatMode.off;

  StreamSubscription<MediaCommand>? _remoteSub;

  QueueViewModel({
    required PersistentLibraryService libraryService,
    ConnectionManager? connectionManager,
  }) : _libraryService = libraryService,
       _connectionManager = connectionManager {
    _loadQueue();
    _remoteSub = _connectionManager?.remoteCommands.listen(
      _handleRemoteCommand,
    );
  }

  void _handleRemoteCommand(MediaCommand command) {
    if (_connectionManager?.isHost ?? false) {
      if (command.type == CommandType.getQueue) {
        _sendQueueData();
      } else if (command.type == CommandType.moveTrack) {
        final oldIndex = (command.payload?['oldIndex'] as num?)?.toInt();
        final newIndex = (command.payload?['newIndex'] as num?)?.toInt();
        if (oldIndex != null && newIndex != null) {
          moveTrack(oldIndex, newIndex);
        }
      } else if (command.type == CommandType.removeTrack) {
        final index = (command.payload?['index'] as num?)?.toInt();
        if (index != null) {
          removeFromQueue(index);
        }
      }
    } else if (_connectionManager?.isClient ?? false) {
      if (command.type == CommandType.queueData) {
        _processRemoteQueueData(command.payload);
      }
    }
  }

  void _sendQueueData() {
    final payload = {
      'items': _queue
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'path': e.path,
              'artistId': e.artistId,
            },
          )
          .toList(),
      'currentIndex': _currentIndex,
    };
    _connectionManager?.sendCommand(
      MediaCommand(type: CommandType.queueData, payload: payload),
    );
  }

  void _processRemoteQueueData(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final items = payload['items'] as List<dynamic>;
    _currentIndex = (payload['currentIndex'] as num?)?.toInt() ?? -1;

    _queue = items
        .map(
          (e) {
            final map = e as Map<String, dynamic>;
            return Track(
              id: map['id'] as int,
              title: map['title'] as String,
              path: map['path'] as String,
              folderId: 0,
              artistId: map['artistId'] as int? ?? 0,
              rating: 0,
            );
          }
        )
        .toList();

    notifyListeners();
  }

  List<Track> get currentQueue => _isShuffle ? _shuffledQueue : _queue;
  List<Track> get history => _history;
  int get currentIndex => _currentIndex;
  bool get isShuffle => _isShuffle;
  engine_domain.RepeatMode get repeatMode => _repeatMode;
  Track? get currentTrack =>
      _currentIndex >= 0 && _currentIndex < currentQueue.length
      ? currentQueue[_currentIndex]
      : null;

  void setShuffle(bool value) {
    if (_isShuffle == value) return;
    _isShuffle = value;
    if (_isShuffle) {
      _shuffledQueue = List.from(_queue)..shuffle();
      if (_currentIndex != -1) {
        final current = _queue[_currentIndex];
        _shuffledQueue.remove(current);
        _shuffledQueue.insert(0, current);
        _currentIndex = 0;
      }
    } else {
      if (_currentIndex != -1) {
        final current = _shuffledQueue[_currentIndex];
        _currentIndex = _queue.indexOf(current);
      }
    }
    notifyListeners();
  }

  void toggleShuffle() {
    setShuffle(!_isShuffle);
  }

  void setRepeatMode(engine_domain.RepeatMode mode) {
    _repeatMode = mode;
    notifyListeners();
  }

  void toggleRepeat() {
    final nextIndex = (_repeatMode.index + 1) % engine_domain.RepeatMode.values.length;
    _repeatMode = engine_domain.RepeatMode.values[nextIndex];
    notifyListeners();
  }

  Future<void> _loadQueue() async {
    if (_connectionManager?.isClient ?? false) {
      _connectionManager?.sendCommand(MediaCommand(type: CommandType.getQueue));
      return;
    }
    _queue = await _libraryService.getQueue();
    notifyListeners();
  }

  Future<void> addToQueue(Track track) async {
    if (_connectionManager?.isClient ?? false) {
      return;
    }
    _queue.add(track);
    if (_isShuffle) {
      _shuffledQueue.add(track);
    }
    await _persistQueue();
    _sendQueueData(); 
    notifyListeners();
  }

  Future<void> addAllToQueue(List<Track> tracks) async {
    if (_connectionManager?.isClient ?? false) return;
    _queue.addAll(tracks);
    if (_isShuffle) {
      _shuffledQueue.addAll(tracks);
    }
    unawaited(_persistQueue());
    _sendQueueData(); 
    notifyListeners();
  }

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    if (_connectionManager?.isClient ?? false) return;
    _queue = List.from(tracks);
    _currentIndex = startIndex;
    if (_isShuffle) {
      _shuffledQueue = List.from(_queue)..shuffle();
      final current = _queue[_currentIndex];
      _shuffledQueue.remove(current);
      _shuffledQueue.insert(0, current);
      _currentIndex = 0;
    }
    unawaited(_persistQueue());
    _sendQueueData(); 
    notifyListeners();
  }

  Future<void> clearQueue() async {
    if (_connectionManager?.isClient ?? false) return;
    _queue = [];
    _shuffledQueue = [];
    _currentIndex = -1;
    unawaited(_persistQueue());
    _sendQueueData(); 
    notifyListeners();
  }

  Future<void> moveTrack(int oldIndex, int newIndex) async {
    if (_connectionManager?.isClient ?? false) {
      _connectionManager?.sendCommand(
        MediaCommand(
          type: CommandType.moveTrack,
          payload: {'oldIndex': oldIndex, 'newIndex': newIndex},
        ),
      );
      return;
    }
    var actualNewIndex = newIndex;
    if (oldIndex < actualNewIndex) {
      actualNewIndex -= 1;
    }
    final targetQueue = _isShuffle ? _shuffledQueue : _queue;
    final Track item = targetQueue.removeAt(oldIndex);
    targetQueue.insert(actualNewIndex, item);

    if (_currentIndex == oldIndex) {
      _currentIndex = actualNewIndex;
    } else if (oldIndex < _currentIndex && actualNewIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && actualNewIndex <= _currentIndex) {
      _currentIndex++;
    }

    await _persistQueue();
    _sendQueueData(); 
    notifyListeners();
  }

  void skipNext() {
    if (_connectionManager?.isClient ?? false) {
      _connectionManager?.sendCommand(MediaCommand(type: CommandType.skipNext));
      return;
    }
    if (_currentIndex != -1) {
      _addToHistory(currentQueue[_currentIndex]);
    }
    if (_currentIndex < currentQueue.length - 1) {
      _currentIndex++;
    } else if (_repeatMode == engine_domain.RepeatMode.all) {
      _currentIndex = 0;
    }
    _sendQueueData(); 
    notifyListeners();
  }

  void skipPrevious() {
    if (_connectionManager?.isClient ?? false) {
      _connectionManager?.sendCommand(MediaCommand(type: CommandType.skipPrev));
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_repeatMode == engine_domain.RepeatMode.all) {
      _currentIndex = currentQueue.length - 1;
    }
    _sendQueueData(); 
    notifyListeners();
  }

  void _addToHistory(Track track) {
    if (!_history.contains(track)) {
      _history.insert(0, track);
      if (_history.length > 50) _history.removeLast();
    }
  }

  Future<void> shuffleDiscovery() async {
    if (_connectionManager?.isClient ?? false) return;
    final allTracks = await _libraryService.getAllTracks();
    if (allTracks.isNotEmpty) {
      final shuffled = List<Track>.from(allTracks)..shuffle();
      await setQueue(shuffled);
    }
  }

  Future<void> updateRating(int trackId, int rating) async {
    if (_connectionManager?.isClient ?? false) return;
    await _libraryService.updateRating(trackId, rating);
    _updateTrackRatingInList(_queue, trackId, rating);
    _updateTrackRatingInList(_shuffledQueue, trackId, rating);
    _updateTrackRatingInList(_history, trackId, rating);
    _sendQueueData();
    notifyListeners();
  }

  void _updateTrackRatingInList(List<Track> list, int id, int rating) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].id == id) {
        list[i] = list[i].copyWith(rating: rating);
      }
    }
  }

  Future<String> getArtistName(int? artistId) async {
    if (artistId == null) return 'Unknown Artist';
    final artists = await _libraryService.getArtists();
    for (final a in artists) {
      if (a.id == artistId) return a.name;
    }
    return 'Unknown Artist';
  }

  Future<String> getAlbumName(int? albumId) async {
    if (albumId == null) return 'Unknown Album';
    final albums = await _libraryService.getAlbums();
    for (final a in albums) {
      if (a.id == albumId) return a.name;
    }
    return 'Unknown Album';
  }

  Future<void> removeFromQueue(int index) async {
    if (_connectionManager?.isClient ?? false) {
      _connectionManager?.sendCommand(
        MediaCommand(type: CommandType.removeTrack, payload: {'index': index}),
      );
      return;
    }
    if (index < 0 || index >= currentQueue.length) return;

    final targetQueue = _isShuffle ? _shuffledQueue : _queue;
    final removedTrack = targetQueue.removeAt(index);

    if (_isShuffle) {
      _queue.remove(removedTrack);
    } else {
      _shuffledQueue.remove(removedTrack);
    }

    if (_currentIndex == index) {
      if (currentQueue.isEmpty) {
        _currentIndex = -1;
      } else {
        if (_currentIndex >= currentQueue.length) {
          _currentIndex = currentQueue.length - 1;
        }
      }
    } else if (index < _currentIndex) {
      _currentIndex--;
    }

    await _persistQueue();
    _sendQueueData();
    notifyListeners();
  }

  Future<void> _persistQueue() async {
    await _libraryService.saveQueue(_queue.map((t) => t.id).toList());
  }

  void setTrackByIndex(int index) {
    if (_connectionManager?.isClient ?? false) {
      _connectionManager?.sendCommand(
        MediaCommand(type: CommandType.skipNext, payload: {'index': index}),
      );
      return;
    }
    if (index >= 0 && index < currentQueue.length) {
      if (_currentIndex != -1) {
        _addToHistory(currentQueue[_currentIndex]);
      }
      _currentIndex = index;
      _sendQueueData();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _remoteSub?.cancel();
    super.dispose();
  }
}
