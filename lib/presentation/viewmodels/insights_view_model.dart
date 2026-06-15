import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/podcast_database.dart' as podcast_db;
import 'package:aulos/data/database/radio_database.dart' as radio_db;

class InsightsViewModel extends ChangeNotifier {
  final AppDatabase _db;
  final podcast_db.PodcastDatabase _podcastDb;
  final radio_db.RadioDatabase _radioDb;

  InsightsViewModel({
    required AppDatabase db,
    required podcast_db.PodcastDatabase podcastDb,
    required radio_db.RadioDatabase radioDb,
  })  : _db = db,
        _podcastDb = podcastDb,
        _radioDb = radioDb;

  // Favorites Streams
  Stream<List<Track>> get favoriteTracks => _db.watchFavoriteTracks();
  Stream<List<Artist>> get favoriteArtists => _db.watchFavoriteArtists();
  Stream<List<Album>> get favoriteAlbums => _db.watchFavoriteAlbums();
  Stream<List<podcast_db.Podcast>> get favoritePodcasts => _podcastDb.watchFavoritePodcasts();

  // Top Items
  Stream<List<Track>> get topTracks => _db.watchMostPlayedTracks(limit: 10);
  Stream<List<radio_db.RadioListeningStat>> get radioStats => _radioDb.watchRadioStats(limit: 5);

  // Actions
  Future<void> toggleTrackFavorite(Track track) => _db.setTrackFavorite(track.id, !track.isFavorite);
  Future<void> toggleArtistFavorite(Artist artist) => _db.setArtistFavorite(artist.id, !artist.isFavorite);
  Future<void> toggleAlbumFavorite(Album album) => _db.setAlbumFavorite(album.id, !album.isFavorite);
  Future<void> togglePodcastFavorite(podcast_db.Podcast podcast) => _podcastDb.setPodcastFavorite(podcast.id, !podcast.isFavorite);

  // Stats Calculations
  Future<Map<String, dynamic>> getLibraryStats() async {
    final tracks = await _db.getAllTracks();
    final artists = await _db.getAllArtists();
    final albums = await _db.getAllAlbums();
    final podcasts = await _podcastDb.getAllPodcasts();

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
