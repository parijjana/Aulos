import 'package:flutter/foundation.dart';
import 'package:aulos/data/library/jamendo_service.dart';
import 'package:aulos/data/library/jamendo_track_downloader.dart';
import 'package:aulos/domain/library/jamendo_track.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/network/log_service.dart';

class JamendoViewModel extends ChangeNotifier {
  final JamendoService _service;
  final JamendoTrackDownloader _downloader;
  final LogService _logService;

  List<JamendoTrack> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, double> _downloadProgress = {};
  JamendoTrack? _selectedTrack;
  String _lastSearchQuery = '';

  JamendoViewModel({
    required JamendoService service,
    required JamendoTrackDownloader downloader,
    LogService? logService,
  }) : _service = service,
       _downloader = downloader,
       _logService = logService ?? NoOpLogService();

  void log(String message) => _logService.log(message);

  List<JamendoTrack> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, double> get downloadProgress => _downloadProgress;
  JamendoTrack? get selectedTrack => _selectedTrack;
  String get lastSearchQuery => _lastSearchQuery;

  void selectTrack(JamendoTrack? track) {
    _selectedTrack = track;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _isLoading = true;
    _error = null;
    _lastSearchQuery = query;
    notifyListeners();

    try {
      _searchResults = await _service.searchTracks(query);
    } catch (e) {
      _error = e.toString();
      log('JAMENDO_VM: Search failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Integrates a track as stream in database, returns the database Track object
  Future<Track> streamTrack(JamendoTrack jamendoTrack) async {
    _error = null;
    notifyListeners();

    try {
      return await _downloader.streamTrack(jamendoTrack);
    } catch (e) {
      log('JAMENDO_VM: Stream integration failed: $e');
      _error = e.toString();
      rethrow;
    }
  }

  /// Downloads track, saves locally, updates path in DB to point to local file, returns database Track object
  Future<Track> downloadTrack(JamendoTrack jamendoTrack) async {
    if (_downloadProgress.containsKey(jamendoTrack.id)) {
      throw Exception('Already downloading this track');
    }
    _downloadProgress[jamendoTrack.id] = 0.0;
    notifyListeners();

    try {
      return await _downloader.downloadTrack(
        jamendoTrack,
        onProgress: (progress) {
          _downloadProgress[jamendoTrack.id] = progress;
          notifyListeners();
        },
      );
    } catch (e) {
      log('JAMENDO_VM: Download failed: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _downloadProgress.remove(jamendoTrack.id);
      notifyListeners();
    }
  }
}
