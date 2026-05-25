import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:aulos/features/noise/models/noise_item.dart';
import 'package:aulos/data/playback/ambient_mixer_service.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as engine_domain;
import 'dart:async';
import 'dart:convert';

class NoiseViewModel extends ChangeNotifier {
  final AmbientMixerService _mixerService;
  final AppDatabase _db;

  final List<NoiseItem> _items = [
    // NATURE
    const NoiseItem(
      id: 'n_ocean_surf',
      title: 'Ocean Surf',
      url: 'asset:///assets/audio/noise/ocean_surf.mp3',
      category: NoiseCategory.nature,
      icon: Icons.waves,
      color: Colors.blue,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'n_ocean_rhythmic',
      title: 'Rhythmic Waves',
      url: 'asset:///assets/audio/noise/ocean_rhythmic.mp3',
      category: NoiseCategory.nature,
      icon: Icons.water,
      color: Colors.lightBlue,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'n_forest_amb',
      title: 'Forest Ambience',
      url: 'asset:///assets/audio/noise/forest_ambience.mp3',
      category: NoiseCategory.nature,
      icon: Icons.park,
      color: Colors.green,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'n_forest_deep',
      title: 'Deep Forest',
      url: 'asset:///assets/audio/noise/forest_deep.mp3',
      category: NoiseCategory.nature,
      icon: Icons.nature_people,
      color: Colors.teal,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'n_rain_heavy',
      title: 'Heavy Rain',
      url: 'asset:///assets/audio/noise/rain_heavy.mp3',
      category: NoiseCategory.nature,
      icon: Icons.umbrella,
      color: Colors.indigo,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'n_thunder',
      title: 'Thunderstorm',
      url: 'asset:///assets/audio/noise/thunderstorm.mp3',
      category: NoiseCategory.nature,
      icon: Icons.thunderstorm,
      color: Colors.deepPurple,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'n_campfire',
      title: 'Campfire',
      url: 'asset:///assets/audio/noise/campfire.mp3',
      category: NoiseCategory.nature,
      icon: Icons.fireplace,
      color: Colors.orangeAccent,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    
    // URBAN
    const NoiseItem(
      id: 'u_traffic',
      title: 'City Street',
      url: 'asset:///assets/audio/noise/city_street.mp3',
      category: NoiseCategory.urban,
      icon: Icons.location_city,
      color: Colors.orange,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    
    // INDUSTRIAL / COLORED NOISE
    const NoiseItem(
      id: 'i_white',
      title: 'White Noise',
      url: 'asset:///assets/audio/noise/white_noise.mp3',
      category: NoiseCategory.industrial,
      icon: Icons.blur_on,
      color: Colors.grey,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'i_pink',
      title: 'Pink Noise',
      url: 'asset:///assets/audio/noise/pink_noise.mp3',
      category: NoiseCategory.industrial,
      icon: Icons.blur_linear,
      color: Colors.pink,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
    const NoiseItem(
      id: 'i_brown',
      title: 'Brown Noise',
      url: 'asset:///assets/audio/noise/brown_noise.mp3',
      category: NoiseCategory.industrial,
      icon: Icons.blur_circular,
      color: Colors.brown,
      source: 'BigSoundBank',
      author: 'CC0 / Public Domain',
    ),
  ];

  Map<String, double> _activeVolumes = {};
  List<SavedMix> _savedMixes = [];
  NoiseCategory _selectedCategory = NoiseCategory.nature;
  String _searchQuery = '';
  bool _isMixPlaying = false;
  double _masterVolume = 1.0;

  NoiseViewModel({
    required AmbientMixerService mixerService,
    required AppDatabase db,
  }) : _mixerService = mixerService,
       _db = db {
    _init();
  }

  Future<void> _init() async {
    _loadSavedMixes();
    for (var item in _items) {
      unawaited(_mixerService.preloadSound(item.id, item.url));
    }
  }

  List<NoiseItem> get allItems => _items;
  Map<String, double> get activeVolumes => _activeVolumes;
  List<SavedMix> get savedMixes => _savedMixes;
  NoiseCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isMixerActive => _activeVolumes.isNotEmpty;
  bool get isPlaying => _isMixPlaying;
  double get masterVolume => _masterVolume;

  List<NoiseItem> get filteredItems {
    return _items.where((item) {
      final matchesCategory = item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategory(NoiseCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleSound(String id, {double defaultVolume = 0.5}) async {
    final item = _items.firstWhere((i) => i.id == id);
    if (_activeVolumes.containsKey(id)) {
      _activeVolumes.remove(id);
      await _mixerService.setSound(id, '', play: false);
    } else {
      _activeVolumes[id] = defaultVolume;
      await _mixerService.setSound(id, item.url, volume: defaultVolume * _masterVolume, play: true);
      _isMixPlaying = true;
    }
    notifyListeners();
  }

  Future<void> setVolume(String id, double volume) async {
    if (_activeVolumes.containsKey(id)) {
      _activeVolumes[id] = volume;
      await _mixerService.setVolume(id, volume * _masterVolume);
      notifyListeners();
    }
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume;
    for (var entry in _activeVolumes.entries) {
      unawaited(_mixerService.setVolume(entry.key, entry.value * _masterVolume));
    }
    notifyListeners();
  }

  Future<void> stopAll() async {
    await _mixerService.stopAll();
    _isMixPlaying = false;
    notifyListeners();
  }

  Future<void> clearMix() async {
    _activeVolumes.clear();
    await _mixerService.stopAll();
    _isMixPlaying = false;
    notifyListeners();
  }

  Future<void> restoreActiveMix() async {
     if (_activeVolumes.isEmpty) return;
     for (var entry in _activeVolumes.entries) {
       final item = _items.firstWhere((i) => i.id == entry.key);
       await _mixerService.setSound(entry.key, item.url, volume: entry.value * _masterVolume, play: true);
     }
     _isMixPlaying = true;
     notifyListeners();
  }

  Future<void> saveCurrentMix(String name) async {
    if (_activeVolumes.isEmpty) return;
    
    final mixData = jsonEncode(_activeVolumes);
    await _db.saveMix(SavedMixesCompanion.insert(
      name: name,
      mixData: mixData,
      createdAt: Value(DateTime.now()),
    ));
    await _loadSavedMixes();
  }

  Future<void> playMix(SavedMix mix) async {
    await clearMix();
    final Map<String, dynamic> data = jsonDecode(mix.mixData);
    
    for (final entry in data.entries) {
      final id = entry.key;
      final volume = (entry.value as num).toDouble();
      final item = _items.firstWhere((i) => i.id == id, orElse: () => _items.first);
      
      _activeVolumes[id] = volume;
      await _mixerService.setSound(id, item.url, volume: volume * _masterVolume, play: true);
    }
    _isMixPlaying = true;
    notifyListeners();
  }

  String get activeIngredientsLabel {
    final active = _items.where((i) => _activeVolumes.containsKey(i.id));
    if (active.isEmpty) return 'No Active Mix';
    return active.map((i) => i.title).join(' & ');
  }

  String get activeAttributions {
    final active = _items.where((i) => _activeVolumes.containsKey(i.id));
    if (active.isEmpty) return 'Select sounds to begin';
    final sources = active.map((i) => '${i.title}: ${i.source}').join(' • ');
    return sources;
  }

  Future<void> deleteMix(int id) async {
    await _db.deleteMix(id);
    await _loadSavedMixes();
  }

  Future<void> _loadSavedMixes() async {
    _savedMixes = await _db.getAllMixes();
    notifyListeners();
  }

  @override
  void dispose() {
    _mixerService.dispose();
    super.dispose();
  }
}
