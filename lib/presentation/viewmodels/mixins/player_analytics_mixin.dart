import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/domain/playback/playback_track.dart';

mixin PlayerAnalyticsMixin on ChangeNotifier {
  AppDatabase? _dbRef;
  RadioDatabase? _radioDbRef;
  Timer? _radioStatsTimer;

  void initAnalyticsMixin(AppDatabase db, RadioDatabase radioDb) {
    _dbRef = db;
    _radioDbRef = radioDb;
  }

  void recordPlayAnalytics(PlaybackTrack track) {
    if (_dbRef == null) return;
    final isMusic = !track.isAudiobook && 
                    !track.id.startsWith('podcast_') && 
                    !track.id.startsWith('radio_') && 
                    !track.id.startsWith('noise_');
    if (isMusic) {
      unawaited(_dbRef!.recordTrackPlay(track.id));
      if (track.artistId != null) unawaited(_dbRef!.recordArtistPlay(track.artistId!));
      if (track.albumId != null) unawaited(_dbRef!.recordAlbumPlay(track.albumId!));
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
