import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:localaudioplayer/data/library/playlist_service.dart';

class PlaylistViewModel extends ChangeNotifier {
  final PersistentLibraryService _libraryService;
  final PlaylistService _playlistService;

  List<Playlist> _playlists = [];
  bool _isLoading = false;

  PlaylistViewModel({
    required PersistentLibraryService libraryService,
    required PlaylistService playlistService,
  }) : _libraryService = libraryService,
       _playlistService = playlistService {
    _loadPlaylists();
  }

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;

  Future<void> _loadPlaylists() async {
    _isLoading = true;
    notifyListeners();
    _playlists = await _libraryService.getPlaylists();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveQueueAsPlaylist(String name, List<Track> tracks) async {
    await _libraryService.savePlaylist(name, tracks.map((t) => t.id).toList());
    await _loadPlaylists();
  }

  Future<void> deletePlaylist(int id) async {
    await _libraryService.deletePlaylist(id);
    await _loadPlaylists();
  }

  Future<void> exportPlaylist(
    String path,
    List<Track> tracks,
    bool isM3U,
  ) async {
    if (isM3U) {
      await _playlistService.exportM3U(path, tracks);
    } else {
      await _playlistService.exportXSPF(path, tracks);
    }
  }

  Future<void> updateRating(int trackId, int rating) async {
    await _libraryService.updateRating(trackId, rating);
    notifyListeners();
  }

  Future<List<Track>> getUpvotedTracks() async {
    final all = await _libraryService.getAllTracks();
    return all.where((t) => t.rating > 0).toList();
  }

  Future<List<Track>> getDownvotedTracks() async {
    final all = await _libraryService.getAllTracks();
    return all.where((t) => t.rating < 0).toList();
  }

  Future<List<Track>> getTracksForPlaylist(int playlistId) =>
      _libraryService.getTracksForPlaylist(playlistId);
}
