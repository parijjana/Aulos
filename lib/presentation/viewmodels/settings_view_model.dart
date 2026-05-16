import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:themer_flutter/themer_flutter.dart';
import 'package:localaudioplayer/presentation/theme/obsidian_audio_theme.dart';
import 'package:localaudioplayer/presentation/theme/midnight_emerald_theme.dart';
import 'package:localaudioplayer/presentation/theme/flat_origami_theme.dart';
import 'package:localaudioplayer/presentation/theme/hatched_monochrome_theme.dart';
import 'package:localaudioplayer/presentation/theme/ruby_glass_theme.dart';
import 'package:localaudioplayer/presentation/theme/amber_glass_theme.dart';
import 'package:localaudioplayer/presentation/theme/ceramic_trio_theme.dart';
import 'package:localaudioplayer/presentation/theme/inverted_hatched_theme.dart';
import 'package:localaudioplayer/presentation/theme/dynamic_glass_theme.dart';
import 'package:localaudioplayer/presentation/theme/dynamic_hatched_theme.dart';
import 'package:localaudioplayer/presentation/theme/dynamic_flat_theme.dart';

enum LibraryViewType { list, grid, orbit }

enum ArtworkShape { square, circle }

class SettingsViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemerModel _currentThemeModel = ObsidianAudioTheme.model;
  List<ThemerModel> _availableThemes = [
    ObsidianAudioTheme.model,
    MidnightEmeraldTheme.model,
    FlatOrigamiTheme.model,
    HatchedMonochromeTheme.model,
    InvertedHatchedTheme.model,
    RubyGlassTheme.model,
    AmberGlassTheme.model,
    CeramicTrioTheme.model,
    DynamicGlassTheme.model,
    DynamicHatchedTheme.model,
    DynamicFlatTheme.model,
  ];
  bool _isScanning = false;

  String _appName = 'My Device';
  String _deviceId = '';
  bool _showHostAnimation = true;
  bool _showRemoteAnimation = true;
  List<String> _monitoredFolders = [];
  LibraryViewType _lastViewType = LibraryViewType.list;
  ArtworkShape _artworkShape = ArtworkShape.square;
  String? _podcastStorageLocation;
  bool _autoDownloadNewEpisodes = false;

  SettingsViewModel(this._prefs) {
    _loadSettings();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      // Use a microtask to avoid notifying listeners during constructor
      Future.microtask(() => scanForThemes());
    }
  }

  void _loadSettings() {
    _appName = _prefs.getString('settings_app_name') ?? 'My Device';
    _deviceId = _prefs.getString('settings_device_id') ?? '';
    if (_deviceId.isEmpty) {
      _deviceId = const Uuid().v4();
      _prefs.setString('settings_device_id', _deviceId);
    }
    _showHostAnimation = _prefs.getBool('settings_show_host_anim') ?? true;
    _showRemoteAnimation = _prefs.getBool('settings_show_remote_anim') ?? true;
    _monitoredFolders =
        _prefs.getStringList('settings_monitored_folders') ?? [];

    final savedTheme = _prefs.getString('settings_theme');
    if (savedTheme != null) {
      final theme = _availableThemes.firstWhere(
        (t) => t.name == savedTheme,
        orElse: () => _availableThemes.first,
      );
      _currentThemeModel = theme;
    }

    final viewTypeIndex = _prefs.getInt('settings_last_view_type') ?? 0;
    _lastViewType = LibraryViewType
        .values[viewTypeIndex.clamp(0, LibraryViewType.values.length - 1)];

    final artworkShapeIndex = _prefs.getInt('settings_artwork_shape') ?? 0;
    _artworkShape = ArtworkShape
        .values[artworkShapeIndex.clamp(0, ArtworkShape.values.length - 1)];

    _podcastStorageLocation = _prefs.getString('settings_podcast_storage');
    _autoDownloadNewEpisodes =
        _prefs.getBool('settings_podcast_auto_download') ?? false;
  }

  ThemerModel get themeModel => _currentThemeModel;
  List<ThemerModel> get availableThemes => _availableThemes;
  bool get isScanning => _isScanning;
  String get appName => _appName;
  String get deviceId => _deviceId;
  bool get showHostAnimation => _showHostAnimation;
  bool get showRemoteAnimation => _showRemoteAnimation;
  List<String> get monitoredFolders => List.unmodifiable(_monitoredFolders);
  LibraryViewType get lastViewType => _lastViewType;
  ArtworkShape get artworkShape => _artworkShape;
  String? get podcastStorageLocation => _podcastStorageLocation;
  bool get autoDownloadNewEpisodes => _autoDownloadNewEpisodes;

  bool get isDynamicTheme => _currentThemeModel.name.contains('Dynamic');

  void setTheme(ThemerModel model) {
    if (_currentThemeModel == model) return;
    _currentThemeModel = model;
    _prefs.setString('settings_theme', model.name);
    notifyListeners();
  }

  void setAppName(String name) {
    _appName = name;
    _prefs.setString('settings_app_name', name);
    notifyListeners();
  }

  void setShowHostAnimation(bool value) {
    _showHostAnimation = value;
    _prefs.setBool('settings_show_host_anim', value);
    notifyListeners();
  }

  void setShowRemoteAnimation(bool value) {
    _showRemoteAnimation = value;
    _prefs.setBool('settings_show_remote_anim', value);
    notifyListeners();
  }

  void setLastViewType(LibraryViewType type) {
    _lastViewType = type;
    _prefs.setInt('settings_last_view_type', type.index);
    notifyListeners();
  }

  void setArtworkShape(ArtworkShape shape) {
    _artworkShape = shape;
    _prefs.setInt('settings_artwork_shape', shape.index);
    notifyListeners();
  }

  void setPodcastStorageLocation(String? path) {
    _podcastStorageLocation = path;
    if (path != null) {
      _prefs.setString('settings_podcast_storage', path);
    } else {
      _prefs.remove('settings_podcast_storage');
    }
    notifyListeners();
  }

  void setAutoDownloadNewEpisodes(bool value) {
    _autoDownloadNewEpisodes = value;
    _prefs.setBool('settings_podcast_auto_download', value);
    notifyListeners();
  }

  void addMonitoredFolder(String path) {
    if (!_monitoredFolders.contains(path)) {
      _monitoredFolders.add(path);
      _prefs.setStringList('settings_monitored_folders', _monitoredFolders);
      notifyListeners();
    }
  }

  void removeMonitoredFolder(String path) {
    if (_monitoredFolders.remove(path)) {
      _prefs.setStringList('settings_monitored_folders', _monitoredFolders);
      notifyListeners();
    }
  }

  Future<void> scanForThemes() async {
    if (_isScanning) return;
    _isScanning = true;
    notifyListeners();

    try {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        final directory = Directory(p.join(Directory.current.path, 'themes'));
        if (directory.existsSync()) {
          final List<FileSystemEntity> entities = await directory
              .list()
              .toList();
          final List<ThemerModel> loadedThemes = [
            ObsidianAudioTheme.model,
            MidnightEmeraldTheme.model,
            FlatOrigamiTheme.model,
            HatchedMonochromeTheme.model,
            InvertedHatchedTheme.model,
            RubyGlassTheme.model,
            AmberGlassTheme.model,
            CeramicTrioTheme.model,
            DynamicGlassTheme.model,
            DynamicHatchedTheme.model,
            DynamicFlatTheme.model,
          ];

          for (var entity in entities) {
            if (entity is File && entity.path.endsWith('.json')) {
              try {
                final content = await entity.readAsString();
                final model = ThemerParser.parse(content);
                if (!loadedThemes.any((t) => t.name == model.name)) {
                  loadedThemes.add(model);
                }
              } catch (e) {
                debugPrint('Failed to parse theme: ${entity.path}');
              }
            }
          }

          _availableThemes = loadedThemes;
        }
      }
    } catch (e) {
      debugPrint('Error scanning for themes: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
}
