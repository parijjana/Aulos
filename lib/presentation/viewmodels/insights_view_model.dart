import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class InsightsViewModel extends ChangeNotifier {
  final AppDatabase _db;

  InsightsViewModel(this._db);

  // Favorites Streams
  Stream<List<Track>> get favoriteTracks => _db.watchFavoriteTracks();
  Stream<List<Artist>> get favoriteArtists => _db.watchFavoriteArtists();
  Stream<List<Album>> get favoriteAlbums => _db.watchFavoriteAlbums();
  Stream<List<Podcast>> get favoritePodcasts => _db.watchFavoritePodcasts();

  // Top Items
  Stream<List<Track>> get topTracks => _db.watchMostPlayedTracks(limit: 10);
  Stream<List<RadioListeningStat>> get radioStats => _db.watchRadioStats(limit: 5);

  // Actions
  Future<void> toggleTrackFavorite(Track track) => _db.setTrackFavorite(track.id, !track.isFavorite);
  Future<void> toggleArtistFavorite(Artist artist) => _db.setArtistFavorite(artist.id, !artist.isFavorite);
  Future<void> toggleAlbumFavorite(Album album) => _db.setAlbumFavorite(album.id, !album.isFavorite);
  Future<void> togglePodcastFavorite(Podcast podcast) => _db.setPodcastFavorite(podcast.id, !podcast.isFavorite);

  // Stats Calculations
  Future<Map<String, dynamic>> getLibraryStats() async {
    final tracks = await _db.getAllTracks();
    final artists = await _db.getAllArtists();
    final albums = await _db.getAllAlbums();
    final podcasts = await _db.getAllPodcasts();

    int totalSeconds = 0;
    for (var t in tracks) {
      totalSeconds += t.durationSeconds ?? 0;
    }

    return {
      'trackCount': tracks.length,
      'artistCount': artists.length,
      'albumCount': albums.length,
      'podcastCount': podcasts.length,
      'totalDuration': Duration(seconds: totalSeconds),
    };
  }
}
