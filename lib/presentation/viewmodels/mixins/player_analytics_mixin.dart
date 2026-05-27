import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/network/log_service.dart';

mixin PlayerAnalyticsMixin on ChangeNotifier, UniversalLog {
  AppDatabase? _dbRef;
  Timer? _radioStatsTimer;

  void initAnalyticsMixin(AppDatabase db) {
    _dbRef = db;
  }

  void recordPlayAnalytics(Track track) {
    if (_dbRef == null) return;
    if (track.id > 0) {
      unawaited(_dbRef!.recordTrackPlay(track.id));
      if (track.artistId != null) unawaited(_dbRef!.recordArtistPlay(track.artistId!));
      if (track.albumId != null) unawaited(_dbRef!.recordAlbumPlay(track.albumId!));
    }
  }

  void startRadioTracking(String? showNotes) {
    if (_dbRef == null) return;
    final parts = showNotes?.split('|');
    final radioUuid = (parts != null && parts.isNotEmpty) ? parts[0] : null;

    if (radioUuid != null && radioUuid.isNotEmpty) {
      _radioStatsTimer?.cancel();
      _radioStatsTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
         unawaited(_dbRef!.recordRadioListen(radioUuid, 30));
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
