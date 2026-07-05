import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/domain/playback/playback_track.dart';
import 'package:drift/drift.dart';

mixin PlayerAnalyticsMixin on ChangeNotifier {
  AppDatabase? _dbRef;
  RadioDatabase? _radioDbRef;
  AudiobookDatabase? _audiobookDbRef;
  PodcastDatabase? _podcastDbRef;
  Timer? _radioStatsTimer;

  void initAnalyticsMixin({
    required AppDatabase db,
    required RadioDatabase radioDb,
    required AudiobookDatabase audiobookDb,
    required PodcastDatabase podcastDb,
  }) {
    _dbRef = db;
    _radioDbRef = radioDb;
    _audiobookDbRef = audiobookDb;
    _podcastDbRef = podcastDb;
  }

  void recordPlayAnalytics(PlaybackTrack track) {
    final isMusic = !track.isAudiobook && 
                    !track.id.startsWith('podcast_') && 
                    !track.id.startsWith('radio_') && 
                    !track.id.startsWith('noise_');

    if (isMusic && _dbRef != null) {
      unawaited(_dbRef!.recordTrackPlay(track.id));
      if (track.artistId != null) unawaited(_dbRef!.recordArtistPlay(track.artistId!));
      if (track.albumId != null) unawaited(_dbRef!.recordAlbumPlay(track.albumId!));
    } else if (track.isAudiobook && _audiobookDbRef != null) {
      unawaited(() async {
        final existing = await _audiobookDbRef!.getTrackById(track.id);
        if (existing != null) {
          await (_audiobookDbRef!.update(_audiobookDbRef!.audiobookTracks)..where((t) => t.id.equals(track.id))).write(
            AudiobookTracksCompanion(
              playCount: Value(existing.playCount + 1),
              lastPlayed: Value(DateTime.now()),
              isPlayed: Value(true),
            ),
          );
        }
        if (track.albumId != null) {
          final book = await _audiobookDbRef!.getAudiobookById(track.albumId!);
          if (book != null) {
            await (_audiobookDbRef!.update(_audiobookDbRef!.audiobooks)..where((a) => a.id.equals(track.albumId!))).write(
              AudiobooksCompanion(
                playCount: Value(book.playCount + 1),
                lastPlayed: Value(DateTime.now()),
              ),
            );
          }
        }
      }());
    } else if (track.id.startsWith('podcast_') && _podcastDbRef != null) {
      unawaited(() async {
        final existing = await (_podcastDbRef!.select(_podcastDbRef!.episodes)..where((e) => e.id.equals(track.id))).getSingleOrNull();
        if (existing != null) {
          await (_podcastDbRef!.update(_podcastDbRef!.episodes)..where((e) => e.id.equals(track.id))).write(
            EpisodesCompanion(
              playCount: Value((existing.playCount ?? 0) + 1),
              lastPlayed: Value(DateTime.now()),
              isPlayed: const Value(true),
            ),
          );
        }
      }());
    }
  }

  void startRadioTracking(String? showNotes) {
    if (_radioDbRef == null) return;
    final parts = showNotes?.split('|');
    final radioUuid = (parts != null && parts.isNotEmpty) ? parts[0] : null;

    if (radioUuid != null && radioUuid.isNotEmpty) {
      _radioStatsTimer?.cancel();
      _radioStatsTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
         unawaited(_radioDbRef!.recordRadioListen(radioUuid, 30));
      });
    }
  }

  void stopRadioTracking() {
    _radioStatsTimer?.cancel();
    _radioStatsTimer = null;
  }

  @override
  void dispose() {
    _radioStatsTimer?.cancel();
    super.dispose();
  }
}
