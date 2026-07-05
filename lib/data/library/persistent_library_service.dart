import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/domain/library/library_service.dart';
import 'package:aulos/data/library/persistent_library_importer.dart';

abstract class PersistentLibraryService {
  Future<List<Folder>> getFolders();
  Future<List<Folder>> getRootFolders({int folderType = 0});
  Future<List<Folder>> getSubFolders(String parentId, {int folderType = 0});
  Future<List<Artist>> getArtists();
  Future<List<Album>> getAlbums();
  Future<List<Genre>> getGenres();
  Future<List<int>> getYears();

  Future<List<Track>> getTracksForFolder(String folderId);
  Future<List<Track>> getTracksForArtist(String artistId);
  Future<List<Track>> getTracksForAlbum(String albumId);
  Future<List<Track>> getTracksForGenre(String genreId);
  Future<List<Track>> getTracksForYear(int year);

  Future<List<Track>> getAllTracks();
  Future<void> importFolder(String path, {VoidCallback? onFileFound, int folderType = 0});
  Future<void> autoDiscoverTracks();
  Future<void> pickAndAddFolder({int folderType = 0});
  Future<void> updateRating(String trackId, int rating);
  Future<void> updateAlbumArt(String albumId, Uint8List art);
  Future<void> updateArtistPhoto(String artistId, Uint8List photo);
  Future<List<Track>> getQueue();
  Future<void> saveQueue(List<String> trackIds);
  Future<List<Playlist>> getPlaylists();
  Future<void> savePlaylist(String name, List<String> trackIds);
  Future<void> saveSmartPlaylist(String name, String rulesJson);
  Future<List<Track>> getTracksForPlaylist(String playlistId);
  Future<void> deletePlaylist(String playlistId);

  // Audiobook Specific
  Future<List<Album>> getAudiobooks();
  Future<List<Track>> getChapters(String bookId);
}

class PersistentLibraryServiceImpl implements PersistentLibraryService {
  final AppDatabase _db;
  final AudiobookDatabase _audiobookDb;
  final LibraryService _scanner;

  PersistentLibraryServiceImpl({
    required AppDatabase db,
    required AudiobookDatabase audiobookDb,
    required LibraryService scanner,
  }) : _db = db,
       _audiobookDb = audiobookDb,
       _scanner = scanner;

  AppDatabase get db => _db;
  AudiobookDatabase get audiobookDb => _audiobookDb;
  LibraryService get scanner => _scanner;

  @override
  Future<List<Folder>> getFolders() => _db.getAllFolders();

  @override
  Future<List<Folder>> getRootFolders({int folderType = 0}) async {
    if (folderType == 1) {
      final list = await _audiobookDb.getRootFolders();
      return list.map((f) => Folder(
        id: f.id,
        path: f.path,
        name: f.name,
        parentId: f.parentId,
        folderType: 1,
      )).toList();
    }
    return _db.getRootFolders(folderType: folderType);
  }

  @override
  Future<List<Folder>> getSubFolders(String parentId, {int folderType = 0}) async {
    if (folderType == 1) {
      final list = await _audiobookDb.getSubFolders(parentId);
      return list.map((f) => Folder(
        id: f.id,
        path: f.path,
        name: f.name,
        parentId: f.parentId,
        folderType: 1,
      )).toList();
    }
    return _db.getSubFolders(parentId, folderType: folderType);
  }

  @override
  Future<List<Artist>> getArtists() => _db.getAllArtists();

  @override
  Future<List<Album>> getAlbums() => _db.getAllAlbums();

  @override
  Future<List<Genre>> getGenres() => _db.getAllGenres();

  @override
  Future<List<int>> getYears() => _db.getAllYears();

  @override
  Future<List<Track>> getTracksForFolder(String folderId) =>
      _db.getTracksForFolder(folderId);

  @override
  Future<List<Track>> getTracksForArtist(String artistId) =>
      _db.getTracksForArtist(artistId);

  @override
  Future<List<Track>> getTracksForAlbum(String albumId) =>
      _db.getTracksForAlbum(albumId);

  @override
  Future<List<Track>> getTracksForGenre(String genreId) =>
      _db.getTracksForGenre(genreId);

  @override
  Future<List<Track>> getTracksForYear(int year) => _db.getTracksForYear(year);

  @override
  Future<List<Track>> getAllTracks() => _db.getAllTracks();

  @override
  Future<List<Album>> getAudiobooks() async {
    final list = await _audiobookDb.getAudiobooks();
    return list.map((a) => Album(
      id: a.id,
      name: a.name,
      artistId: a.artistId,
      coverArt: a.coverArt,
      coverArtUrl: a.coverArtUrl,
      isFavorite: a.isFavorite,
      playCount: a.playCount,
      lastPlayed: a.lastPlayed,
      isAudiobook: true,
      asin: a.asin,
      subtitle: a.subtitle,
      seriesName: a.seriesName,
      seriesPosition: a.seriesPosition,
      narrator: a.narrator,
      description: a.description,
      publisher: a.publisher,
      publishedDate: a.publishedDate,
      isPlayed: a.isPlayed,
      librivoxId: a.librivoxId,
      isDownloadedViaAulos: a.isDownloadedViaAulos,
    )).toList();
  }

  @override
  Future<List<Track>> getChapters(String bookId) async {
    final list = await _audiobookDb.getTracksForBook(bookId);
    return list.map((t) => Track(
      id: t.id,
      path: t.path,
      title: t.title,
      artistId: t.artistId,
      albumId: t.audiobookId,
      genreId: null,
      year: null,
      durationSeconds: t.durationSeconds,
      folderId: '',
      rating: t.rating,
      coverArt: t.coverArt,
      isFavorite: t.isFavorite,
      playCount: t.playCount,
      lastPlayed: t.lastPlayed,
      isAudiobook: true,
      isPlayed: t.isPlayed,
      isStream: t.isStream,
    )).toList();
  }

  @override
  Future<void> pickAndAddFolder({int folderType = 0}) =>
      PersistentLibraryImportExtension(this).pickAndAddFolder(folderType: folderType);

  @override
  Future<void> importFolder(String path, {VoidCallback? onFileFound, int folderType = 0}) =>
      PersistentLibraryImportExtension(this).importFolder(path, onFileFound: onFileFound, folderType: folderType);

  @override
  Future<void> autoDiscoverTracks() =>
      PersistentLibraryImportExtension(this).autoDiscoverTracks();

  @override
  Future<void> updateRating(String trackId, int rating) =>
      _db.updateTrackRating(trackId, rating);

  @override
  Future<void> updateAlbumArt(String albumId, Uint8List art) =>
      _db.updateAlbumArt(albumId, art);

  @override
  Future<void> updateArtistPhoto(String artistId, Uint8List photo) =>
      _db.updateArtistPhoto(artistId, photo);

  @override
  Future<List<Track>> getQueue() async {
    final queueItems = await (_db.select(_db.queueTracks)..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    if (queueItems.isEmpty) return [];

    final trackIds = queueItems.map((qi) => qi.trackId).toList();

    final musicTracksList = await (_db.select(_db.tracks)..where((t) => t.id.isIn(trackIds))).get();
    final Map<String, Track> musicMap = {for (var t in musicTracksList) t.id: t};

    final audiobookTracksList = await (_audiobookDb.select(_audiobookDb.audiobookTracks)..where((t) => t.id.isIn(trackIds))).get();
    final Map<String, Track> audiobookMap = {
      for (var t in audiobookTracksList)
        t.id: Track(
          id: t.id,
          path: t.path,
          title: t.title,
          artistId: t.artistId,
          albumId: t.audiobookId,
          genreId: null,
          year: null,
          durationSeconds: t.durationSeconds,
          folderId: 'audiobook_folder',
          rating: t.rating,
          coverArt: t.coverArt,
          isFavorite: t.isFavorite,
          playCount: t.playCount,
          lastPlayed: t.lastPlayed,
          isAudiobook: true,
          isPlayed: t.isPlayed,
          isStream: t.isStream,
        )
    };

    final List<Track> result = [];
    for (final item in queueItems) {
      final id = item.trackId;
      if (musicMap.containsKey(id)) {
        result.add(musicMap[id]!);
      } else if (audiobookMap.containsKey(id)) {
        result.add(audiobookMap[id]!);
      }
    }
    return result;
  }

  @override
  Future<void> saveQueue(List<String> trackIds) => _db.saveQueue(trackIds);

  @override
  Future<List<Playlist>> getPlaylists() => _db.getAllPlaylists();

  @override
  Future<void> savePlaylist(String name, List<String> trackIds) =>
      _db.savePlaylistWithTracks(name, trackIds);

  @override
  Future<void> saveSmartPlaylist(String name, String rulesJson) =>
      _db.saveSmartPlaylist(name, rulesJson);

  @override
  Future<List<Track>> getTracksForPlaylist(String playlistId) async {
    final playlist = await (_db.select(_db.playlists)..where((t) => t.id.equals(playlistId))).getSingleOrNull();
    if (playlist == null) return [];

    if (playlist.isSmart) {
      if (playlist.rulesJson != null && playlist.rulesJson!.isNotEmpty) {
        return _db.getTracksForPlaylist(playlistId);
      }
      final List<Track> combinedTracks = [];

      if (playlist.name == 'Likes') {
        final musicLikes = await (_db.select(_db.tracks)..where((t) => t.isFavorite.equals(true))).get();
        combinedTracks.addAll(musicLikes);

        final audiobookLikes = await (_audiobookDb.select(_audiobookDb.audiobookTracks)..where((t) => t.isFavorite.equals(true))).get();
        combinedTracks.addAll(audiobookLikes.map((t) => _mapAudiobookTrackToTrack(t)));

        return combinedTracks;
      } else if (playlist.name == 'Dislikes') {
        final musicDislikes = await (_db.select(_db.tracks)..where((t) => t.rating.equals(-1))).get();
        combinedTracks.addAll(musicDislikes);

        final audiobookDislikes = await (_audiobookDb.select(_audiobookDb.audiobookTracks)..where((t) => t.rating.equals(-1))).get();
        combinedTracks.addAll(audiobookDislikes.map((t) => _mapAudiobookTrackToTrack(t)));

        return combinedTracks;
      } else if (playlist.name == 'Recently Played') {
        final musicRecently = await (_db.select(_db.tracks)
          ..where((t) => t.lastPlayed.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lastPlayed)])
          ..limit(50)
        ).get();
        combinedTracks.addAll(musicRecently);

        final audiobookRecently = await (_audiobookDb.select(_audiobookDb.audiobookTracks)
          ..where((t) => t.lastPlayed.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lastPlayed)])
          ..limit(50)
        ).get();
        combinedTracks.addAll(audiobookRecently.map((t) => _mapAudiobookTrackToTrack(t)));

        combinedTracks.sort((a, b) {
          if (a.lastPlayed == null) return 1;
          if (b.lastPlayed == null) return -1;
          return b.lastPlayed!.compareTo(a.lastPlayed!);
        });
        return combinedTracks.take(50).toList();
      } else if (playlist.name == 'Most Played') {
        final musicMost = await (_db.select(_db.tracks)
          ..where((t) => t.playCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.playCount)])
          ..limit(50)
        ).get();
        combinedTracks.addAll(musicMost);

        final audiobookMost = await (_audiobookDb.select(_audiobookDb.audiobookTracks)
          ..where((t) => t.playCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.playCount)])
          ..limit(50)
        ).get();
        combinedTracks.addAll(audiobookMost.map((t) => _mapAudiobookTrackToTrack(t)));

        combinedTracks.sort((a, b) => b.playCount.compareTo(a.playCount));
        return combinedTracks.take(50).toList();
      } else if (playlist.name == 'Recently Added') {
        final musicAdded = await (_db.select(_db.tracks)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(50)
        ).get();
        combinedTracks.addAll(musicAdded);

        final audiobookAdded = await (_audiobookDb.select(_audiobookDb.audiobookTracks)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(50)
        ).get();
        combinedTracks.addAll(audiobookAdded.map((t) => _mapAudiobookTrackToTrack(t)));

        combinedTracks.sort((a, b) => b.id.compareTo(a.id));
        return combinedTracks.take(50).toList();
      }
    }

    return _db.getTracksForPlaylist(playlistId);
  }

  Track _mapAudiobookTrackToTrack(AudiobookTrack t) {
    return Track(
      id: t.id,
      path: t.path,
      title: t.title,
      artistId: t.artistId,
      albumId: t.audiobookId,
      genreId: null,
      year: null,
      durationSeconds: t.durationSeconds,
      folderId: 'audiobook_folder',
      rating: t.rating,
      coverArt: t.coverArt,
      isFavorite: t.isFavorite,
      playCount: t.playCount,
      lastPlayed: t.lastPlayed,
      isAudiobook: true,
      isPlayed: t.isPlayed,
      isStream: t.isStream,
    );
  }

  @override
  Future<void> deletePlaylist(String playlistId) => _db.deletePlaylist(playlistId);

  // Partial Views
  Future<List<Album>> getAlbumsForArtist(String artistId) async {
    final query = _db.select(_db.artistAlbumRelations).join([
      innerJoin(
        _db.albums,
        _db.albums.id.equalsExp(_db.artistAlbumRelations.albumId),
      ),
    ])..where(_db.artistAlbumRelations.artistId.equals(artistId));

    final result = await query.get();
    return result.map((row) => row.readTable(_db.albums)).toList();
  }

  Future<List<Track>> getTracksForArtistInAlbum(String artistId, String albumId) =>
      _db.getTracksForArtistInAlbum(artistId, albumId);

  Future<List<Album>> getAlbumsForGenre(String genreId) async {
    final query = _db.selectOnly(_db.tracks, distinct: true)
      ..addColumns([_db.tracks.albumId])
      ..where(_db.tracks.genreId.equals(genreId));
    final rows = await query.get();
    final albumIds = rows
        .map((r) => r.read(_db.tracks.albumId))
        .whereType<String>()
        .toList();
    return (_db.select(_db.albums)..where((a) => a.id.isIn(albumIds))).get();
  }

  Future<List<Album>> getAlbumsForYear(int year) async {
    final query = _db.selectOnly(_db.tracks, distinct: true)
      ..addColumns([_db.tracks.albumId])
      ..where(_db.tracks.year.equals(year));
    final rows = await query.get();
    final albumIds = rows
        .map((r) => r.read(_db.tracks.albumId))
        .whereType<String>()
        .toList();
    return (_db.select(_db.albums)..where((a) => a.id.isIn(albumIds))).get();
  }

  Future<List<Track>> getTracksForGenreInAlbum(String genreId, String albumId) =>
      (_db.select(_db.tracks)..where(
            (t) => t.genreId.equals(genreId) & t.albumId.equals(albumId),
          ))
          .get();

  Future<List<Track>> getTracksForYearInAlbum(int year, String albumId) =>
      (_db.select(
        _db.tracks,
      )..where((t) => t.year.equals(year) & t.albumId.equals(albumId))).get();
}
