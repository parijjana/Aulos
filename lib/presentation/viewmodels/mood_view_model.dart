import 'package:flutter/foundation.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/data/database/app_database.dart' as app_db;
import 'package:aulos/data/database/podcast_database.dart' as podcast_db;
import 'package:aulos/data/database/audiobook_database.dart' as audiobook_db;
import 'package:aulos/data/database/noise_database.dart' as noise_db;
import 'package:aulos/data/database/radio_database.dart' as radio_db;
import 'package:drift/drift.dart';

class MoodItemData {
  final String title;
  final String subtitle;
  final Uint8List? coverArt;
  final String? imageUrl;
  final app_db.Track? track;
  final noise_db.SavedMix? noiseMix;
  final String? description;

  MoodItemData({
    required this.title,
    required this.subtitle,
    this.coverArt,
    this.imageUrl,
    this.track,
    this.noiseMix,
    this.description,
  });
}

class MoodViewModel extends ChangeNotifier {
  final SettingsViewModel _settingsVM;
  final app_db.AppDatabase _appDb;
  final podcast_db.PodcastDatabase _podcastDb;
  final audiobook_db.AudiobookDatabase _audiobookDb;
  final noise_db.NoiseDatabase _noiseDb;
  final radio_db.RadioDatabase _radioDb;

  MoodItemData? lastMusic;
  MoodItemData? lastPodcast;
  MoodItemData? lastAudiobook;
  MoodItemData? lastNoise;
  MoodItemData? lastRadio;

  bool isLoading = true;
  bool _firstLoad = true;

  MoodViewModel({
    required SettingsViewModel settingsVM,
    required app_db.AppDatabase appDb,
    required podcast_db.PodcastDatabase podcastDb,
    required audiobook_db.AudiobookDatabase audiobookDb,
    required noise_db.NoiseDatabase noiseDb,
    required radio_db.RadioDatabase radioDb,
  })  : _settingsVM = settingsVM,
        _appDb = appDb,
        _podcastDb = podcastDb,
        _audiobookDb = audiobookDb,
        _noiseDb = noiseDb,
        _radioDb = radioDb {
    _settingsVM.addListener(_onSettingsChanged);
    loadLastPlayedItems();
  }

  void _onSettingsChanged() {
    loadLastPlayedItems();
  }

  @override
  void dispose() {
    _settingsVM.removeListener(_onSettingsChanged);
    super.dispose();
  }

  Future<void> loadLastPlayedItems() async {
    if (_firstLoad) {
      isLoading = true;
      notifyListeners();
    }

    await Future.wait([
      _loadLastMusic(),
      _loadLastPodcast(),
      _loadLastAudiobook(),
      _loadLastNoise(),
      _loadLastRadio(),
    ]);

    if (_firstLoad) {
      _firstLoad = false;
      isLoading = false;
    }
    notifyListeners();
  }

  Future<void> _loadLastRadio() async {
    final uuid = _settingsVM.lastRadioStationUuid;
    if (uuid == null) return;

    final station = await (_radioDb.select(_radioDb.radioStations)..where((s) => s.stationUuid.equals(uuid))).getSingleOrNull();
    if (station != null) {
      // Need to construct a synthetic Track for Radio.
      final synthTrack = app_db.Track(
        id: station.stationUuid,
        path: station.url,
        title: station.name,
        durationSeconds: 0,
        rating: 0,
        isFavorite: station.isFavorite,
        playCount: 0,
        isPlayed: false,
        isStream: true,
        isAudiobook: false,
        folderId: 'radio_synth_folder', // required by Track
      );
      lastRadio = MoodItemData(
        title: station.name,
        subtitle: (station.country?.isNotEmpty ?? false) ? station.country! : 'Internet Radio',
        imageUrl: (station.favicon?.isNotEmpty ?? false) ? station.favicon : null,
        track: synthTrack,
        description: station.tags,
      );
    }
  }

  Future<void> _loadLastMusic() async {
    final id = _settingsVM.lastMusicTrackId;
    if (id == null) return;

    final track = await (_appDb.select(_appDb.tracks)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (track != null) {
      String subtitle = 'Unknown Artist';
      if (track.artistId != null) {
        final artist = await (_appDb.select(_appDb.artists)..where((a) => a.id.equals(track.artistId!))).getSingleOrNull();
        if (artist != null) subtitle = artist.name;
      }
      
      Uint8List? art = track.coverArt;
      if (art == null && track.albumId != null) {
        final album = await (_appDb.select(_appDb.albums)..where((a) => a.id.equals(track.albumId!))).getSingleOrNull();
        if (album != null) art = album.coverArt;
      }

      lastMusic = MoodItemData(
        title: track.title,
        subtitle: subtitle,
        coverArt: art,
        track: track,
      );
    }
  }

  Future<void> _loadLastPodcast() async {
    final id = _settingsVM.lastPodcastEpisodeId;
    if (id == null) return;

    final episode = await (_podcastDb.select(_podcastDb.episodes)..where((e) => e.id.equals(id))).getSingleOrNull();
    if (episode != null) {
      final podcast = await (_podcastDb.select(_podcastDb.podcasts)..where((p) => p.id.equals(episode.podcastId))).getSingleOrNull();
      
      final track = app_db.Track(
        id: 'podcast_${episode.id}',
        path: episode.downloadState == 2 ? (episode.localFilePath ?? episode.audioUrl) : episode.audioUrl,
        title: episode.title,
        artistId: 'podcast_artist',
        folderId: 'podcast_folder',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );

      lastPodcast = MoodItemData(
        title: episode.title,
        subtitle: podcast?.title ?? 'Podcast',
        imageUrl: podcast?.imageUrl,
        track: track,
        description: episode.description,
      );
    }
  }

  Future<void> _loadLastAudiobook() async {
    final id = _settingsVM.lastAudiobookTrackId;
    if (id == null) return;

    final track = await _audiobookDb.getTrackById(id);
    if (track != null) {
      String subtitle = 'Unknown Author';
      Uint8List? art = track.coverArt;

      if (track.audiobookId != null) {
         final book = await _audiobookDb.getAudiobookById(track.audiobookId!);
         if (book != null) {
           subtitle = book.name;
           if (art == null) art = book.coverArt;
         }
      }

      final appTrack = app_db.Track(
        id: track.id,
        path: track.path,
        title: track.title,
        artistId: track.artistId,
        albumId: track.audiobookId,
        folderId: 'audiobook_folder',
        coverArt: track.coverArt,
        durationSeconds: track.durationSeconds ?? 0,
        rating: track.rating,
        isFavorite: track.isFavorite,
        playCount: track.playCount,
        lastPlayed: track.lastPlayed,
        isAudiobook: true,
        isPlayed: track.isPlayed,
      );

      lastAudiobook = MoodItemData(
        title: track.title,
        subtitle: subtitle,
        coverArt: art,
        track: appTrack,
      );
    }
  }

  Future<void> _loadLastNoise() async {
    final id = _settingsVM.lastNoiseTrackId;
    if (id == null) return;

    final mix = await (_noiseDb.select(_noiseDb.savedMixes)..where((m) => m.id.equals(id))).getSingleOrNull();
    if (mix != null) {
      lastNoise = MoodItemData(
        title: mix.name,
        subtitle: 'Ambient Noise',
        noiseMix: mix,
      );
    }
  }
}
