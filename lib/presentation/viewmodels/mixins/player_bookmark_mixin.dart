import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/domain/playback/playback_track.dart';
import 'package:aulos/core/utils/id_generator.dart';

mixin PlayerBookmarkMixin on ChangeNotifier {
  LogService get logService;
  PlaybackDatabase? _playbackDb;
  PodcastDatabase? _podcastDb;
  
  bool _isBookmarkMode = false;
  double _bookmarkStartMs = 0;
  double _bookmarkEndMsVal = 0;

  bool get isBookmarkMode => _isBookmarkMode;
  double get bookmarkStartMs => _bookmarkStartMs;
  double get bookmarkEndMsVal => _bookmarkEndMsVal;

  void initBookmarkMixin(PlaybackDatabase playbackDb, PodcastDatabase podcastDb) {
    _playbackDb = playbackDb;
    _podcastDb = podcastDb;
  }

  void setBookmarkRange(double start, double end) {
    _bookmarkStartMs = start;
    _bookmarkEndMsVal = end;
    notifyListeners();
  }

  void toggleBookmarkMode({Duration? currentPosition, Duration? totalDuration}) {
    _isBookmarkMode = !_isBookmarkMode;
    if (_isBookmarkMode && currentPosition != null && totalDuration != null) {
      final pos = currentPosition.inMilliseconds.toDouble();
      final dur = totalDuration.inMilliseconds.toDouble();
      _bookmarkStartMs = (pos - 10000).clamp(0, dur);
      _bookmarkEndMsVal = (pos + 20000).clamp(0, dur);
    }
    notifyListeners();
  }

  Future<void> saveRichBookmark({
    required PlaybackTrack track,
    required String title,
    required bool isAudiobook,
    required bool isPodcast,
    String? tags,
    String? notes,
  }) async {
    if (_playbackDb == null) return;
    
    final startMs = _bookmarkStartMs.toInt();
    final endMs = _bookmarkEndMsVal.toInt();
    
    // contextType: 0: Music, 1: Podcast, 2: Audiobook
    int contextType = 0;
    if (isPodcast) contextType = 1;
    if (isAudiobook) contextType = 2;

    logService.log('PLAYER: Saving rich bookmark "$title" (Context: $contextType)');
    try {
      final fingerprint = "${track.path}|$title|$startMs|$endMs|${DateTime.now().millisecondsSinceEpoch}";
      final bookmarkId = generateContentId(fingerprint);

      await _playbackDb!.saveBookmark(BookmarksCompanion.insert(
        id: bookmarkId,
        trackPath: track.path,
        title: title,
        startTimeMs: startMs,
        endTimeMs: Value(endMs),
        tags: Value(tags),
        notes: Value(notes),
        contextType: Value(contextType),
      ));
      
      if (isPodcast && _podcastDb != null) {
        await _podcastDb!.updateEpisodePlayback(track.id, isPinned: true);
      }

      _isBookmarkMode = false;
      notifyListeners();
    } catch (e) {
      logService.log('PLAYER_ERROR: Failed to save bookmark: $e');
    }
  }
  
  void resetBookmarkState() {
    _isBookmarkMode = false;
    notifyListeners();
  }
}
