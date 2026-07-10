import 'package:flutter/foundation.dart';
import 'package:aulos/data/library/storage_manager_service.dart';

class StorageCacheViewModel extends ChangeNotifier {
  final StorageManagerService _storageService;
  
  int _podcastSize = 0;
  int _audiobookSize = 0;
  bool _isLoading = false;

  StorageCacheViewModel(this._storageService) {
    refreshSizes();
  }

  int get podcastSize => _podcastSize;
  int get audiobookSize => _audiobookSize;
  bool get isLoading => _isLoading;
  int get totalSize => _podcastSize + _audiobookSize;

  Future<void> refreshSizes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final podcastBytes = await _storageService.getPodcastCacheSize();
      final audiobookBytes = await _storageService.getAudiobookCacheSize();
      _podcastSize = podcastBytes;
      _audiobookSize = audiobookBytes;
    } catch (e) {
      debugPrint('StorageCacheViewModel: Failed to refresh storage sizes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openPodcastFolder() async {
    await _storageService.openPodcastFolder();
    // Refresh size afterward since the user might delete files
    await refreshSizes();
  }

  Future<void> openAudiobookFolder() async {
    await _storageService.openAudiobookFolder();
    // Refresh size afterward since the user might delete files
    await refreshSizes();
  }
}
