import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:themer_flutter/themer_flutter.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:aulos/presentation/theme/amber_glass_theme.dart';
import 'package:aulos/presentation/theme/ceramic_trio_theme.dart';
import 'package:aulos/presentation/theme/dynamic_flat_theme.dart';
import 'package:aulos/presentation/theme/dynamic_glass_theme.dart';
import 'package:aulos/presentation/theme/dynamic_hatched_theme.dart';
import 'package:aulos/presentation/theme/flat_origami_theme.dart';
import 'package:aulos/presentation/theme/hatched_monochrome_theme.dart';
import 'package:aulos/presentation/theme/inverted_hatched_theme.dart';
import 'package:aulos/presentation/theme/midnight_emerald_theme.dart';
import 'package:aulos/presentation/theme/ruby_glass_theme.dart';

enum ArtworkShape { square, circle }
enum LibraryViewType { list, grid, orbit }

class SettingsViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsViewModel(this._prefs) {
    _loadSettings();
  }

  String _appName = 'Aulos';
  String _deviceId = const Uuid().v4();
  List<String> _monitoredFolders = [];
  ThemerModel _themeModel = AulosAudioTheme.model; 
  bool _isDynamicTheme = true;
  ArtworkShape _artworkShape = ArtworkShape.square;
  LibraryViewType _libraryViewType = LibraryViewType.grid;

  int _mainTabIndex = 0;
  int _libraryHubTabIndex = 0;

  bool _showHostAnimation = true;
  bool _showRemoteAnimation = true;

  // Last Played Session State
  String? _lastRadioStationUuid;
  int? _lastPodcastEpisodeId;

  // Podcast Settings
  String? _podcastStorageLocation;
  bool _autoDownloadNewEpisodes = false;
  int _podcastKeepCount = 5; 
  int _podcastKeepDays = 30; 

  // Getters
  String get appName => _appName;
  String get deviceId => _deviceId;
  List<String> get monitoredFolders => List.unmodifiable(_monitoredFolders);
  ThemerModel get themeModel => _themeModel;
  bool get isDynamicTheme => _isDynamicTheme;
  ArtworkShape get artworkShape => _artworkShape;
  LibraryViewType get libraryViewType => _libraryViewType;
  LibraryViewType get lastViewType => _libraryViewType;
  int get mainTabIndex => _mainTabIndex;
  int get libraryHubTabIndex => _libraryHubTabIndex;
  bool get showHostAnimation => _showHostAnimation;
  bool get showRemoteAnimation => _showRemoteAnimation;
  String? get lastRadioStationUuid => _lastRadioStationUuid;
  int? get lastPodcastEpisodeId => _lastPodcastEpisodeId;
  String? get podcastStorageLocation => _podcastStorageLocation;
  bool get autoDownloadNewEpisodes => _autoDownloadNewEpisodes;
  int get podcastKeepCount => _podcastKeepCount;
  int get podcastKeepDays => _podcastKeepDays;

  final List<ThemerModel> _availableThemes = [
    AulosAudioTheme.model,
    AmberGlassTheme.model,
    CeramicTrioTheme.model,
    DynamicFlatTheme.model,
    DynamicGlassTheme.model,
    DynamicHatchedTheme.model,
    FlatOrigamiTheme.model,
    HatchedMonochromeTheme.model,
    InvertedHatchedTheme.model,
    MidnightEmeraldTheme.model,
    RubyGlassTheme.model,
  ];
  List<ThemerModel> get availableThemes => _availableThemes;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  void _loadSettings() {
    _appName = _prefs.getString('app_name') ?? 'Aulos';
    _deviceId = _prefs.getString('device_id') ?? const Uuid().v4();
    _monitoredFolders = _prefs.getStringList('monitored_folders') ?? [];
    _isDynamicTheme = _prefs.getBool('is_dynamic_theme') ?? true;
    _artworkShape = ArtworkShape.values[_prefs.getInt('artwork_shape') ?? 0];
    _libraryViewType = LibraryViewType.values[_prefs.getInt('library_view_type') ?? 1];
    _mainTabIndex = _prefs.getInt('main_tab_index') ?? 0;
    _libraryHubTabIndex = _prefs.getInt('library_hub_tab_index') ?? 0;
    _showHostAnimation = _prefs.getBool('show_host_animation') ?? true;
    _showRemoteAnimation = _prefs.getBool('show_remote_animation') ?? true;
    _lastRadioStationUuid = _prefs.getString('last_radio_station_uuid');
    _lastPodcastEpisodeId = _prefs.getInt('last_podcast_episode_id');
    _podcastStorageLocation = _prefs.getString('podcast_storage_location');
    _autoDownloadNewEpisodes = _prefs.getBool('auto_download_podcasts') ?? false;
    _podcastKeepCount = _prefs.getInt('podcast_keep_count') ?? 5;
    _podcastKeepDays = _prefs.getInt('podcast_keep_days') ?? 30;

    final themeName = _prefs.getString('theme_name');
    if (themeName != null) {
      try {
        _themeModel = _availableThemes.firstWhere((t) => t.name == themeName);
      } catch (_) {
        _themeModel = AulosAudioTheme.model;
      }
    }
  }

  Future<void> setLastRadioStation(String? uuid) async {
    _lastRadioStationUuid = uuid;
    if (uuid == null) {
      await _prefs.remove('last_radio_station_uuid');
    } else {
      await _prefs.setString('last_radio_station_uuid', uuid);
    }
    notifyListeners();
  }

  Future<void> setLastPodcastEpisode(int? id) async {
    _lastPodcastEpisodeId = id;
    if (id == null) {
      await _prefs.remove('last_podcast_episode_id');
    } else {
      await _prefs.setInt('last_podcast_episode_id', id);
    }
    notifyListeners();
  }

  Future<void> setMainTabIndex(int index) async {
    _mainTabIndex = index;
    await _prefs.setInt('main_tab_index', index);
    notifyListeners();
  }

  Future<void> setLibraryHubTabIndex(int index) async {
    _libraryHubTabIndex = index;
    await _prefs.setInt('library_hub_tab_index', index);
    notifyListeners();
  }

  Future<void> setAppName(String name) async {
    _appName = name;
    await _prefs.setString('app_name', name);
    notifyListeners();
  }

  Future<void> addMonitoredFolder(String path) async {
    if (!_monitoredFolders.contains(path)) {
      _monitoredFolders.add(path);
      await _prefs.setStringList('monitored_folders', _monitoredFolders);
      notifyListeners();
    }
  }

  Future<void> removeMonitoredFolder(String path) async {
    if (_monitoredFolders.remove(path)) {
      await _prefs.setStringList('monitored_folders', _monitoredFolders);
      notifyListeners();
    }
  }

  Future<void> setTheme(ThemerModel theme) async {
    _themeModel = theme;
    await _prefs.setString('theme_name', theme.name);
    notifyListeners();
  }

  Future<void> setArtworkShape(ArtworkShape shape) async {
    _artworkShape = shape;
    await _prefs.setInt('artwork_shape', shape.index);
    notifyListeners();
  }

  Future<void> setLibraryViewType(LibraryViewType type) async {
    _libraryViewType = type;
    await _prefs.setInt('library_view_type', type.index);
    notifyListeners();
  }

  Future<void> setLastViewType(LibraryViewType type) => setLibraryViewType(type);

  Future<void> setShowHostAnimation(bool show) async {
    _showHostAnimation = show;
    await _prefs.setBool('show_host_animation', show);
    notifyListeners();
  }

  Future<void> setShowRemoteAnimation(bool show) async {
    _showRemoteAnimation = show;
    await _prefs.setBool('show_remote_animation', show);
    notifyListeners();
  }

  Future<void> setPodcastStorageLocation(String path) async {
    _podcastStorageLocation = path;
    await _prefs.setString('podcast_storage_location', path);
    notifyListeners();
  }

  Future<void> setAutoDownloadNewEpisodes(bool val) async {
    _autoDownloadNewEpisodes = val;
    await _prefs.setBool('auto_download_podcasts', val);
    notifyListeners();
  }

  Future<void> setPodcastKeepCount(int count) async {
    _podcastKeepCount = count;
    await _prefs.setInt('podcast_keep_count', count);
    notifyListeners();
  }

  Future<void> setPodcastKeepDays(int days) async {
    _podcastKeepDays = days;
    await _prefs.setInt('podcast_keep_days', days);
    notifyListeners();
  }
}
