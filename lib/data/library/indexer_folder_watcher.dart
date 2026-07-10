import 'dart:async';
import 'dart:io';

import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';

/// Owns the filesystem-watcher subscriptions for [LibraryIndexerService]:
/// tracks the monitored/audiobook folder lists, starts/stops `Directory`
/// watchers, and debounces background rescans when files change on disk.
///
/// Extracted from LibraryIndexerService verbatim (same logic, same fields)
/// so the watcher lifecycle lives in one cohesive unit.
class IndexerFolderWatcher {
  final SettingsViewModel? settingsVM;
  final PersistentLibraryService? libService;
  final void Function(String message) log;
  final IndexerState Function() currentState;
  final Future<void> Function(List<String> folders, PersistentLibraryService service, {int folderType}) scanLibrary;

  Timer? _watchDebounceTimer;
  final List<StreamSubscription<dynamic>> _watchSubscriptions = [];
  bool? _lastWatcherEnabled;
  List<String>? _lastMonitoredFolders;
  List<String>? _lastAudiobookFolders;

  IndexerFolderWatcher({
    required this.settingsVM,
    required this.libService,
    required this.log,
    required this.currentState,
    required this.scanLibrary,
  }) {
    if (settingsVM != null && libService != null) {
      settingsVM!.addListener(onSettingsChanged);
      _lastWatcherEnabled = settingsVM!.isFolderWatcherEnabled;
      _lastMonitoredFolders = List.from(settingsVM!.monitoredFolders);
      _lastAudiobookFolders = List.from(settingsVM!.audiobookFolders);
      updateWatcherSubscriptions();
    }
  }

  void onSettingsChanged() {
    if (settingsVM == null) return;
    final enabled = settingsVM!.isFolderWatcherEnabled;
    final monitored = settingsVM!.monitoredFolders;
    final audiobooks = settingsVM!.audiobookFolders;

    bool listEquals(List<String> a, List<String> b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    if (_lastWatcherEnabled == enabled &&
        _lastMonitoredFolders != null &&
        listEquals(_lastMonitoredFolders!, monitored) &&
        _lastAudiobookFolders != null &&
        listEquals(_lastAudiobookFolders!, audiobooks)) {
      return;
    }

    _lastWatcherEnabled = enabled;
    _lastMonitoredFolders = List.from(monitored);
    _lastAudiobookFolders = List.from(audiobooks);

    updateWatcherSubscriptions();
  }

  void updateWatcherSubscriptions() {
    if (settingsVM == null || libService == null) return;

    for (var sub in _watchSubscriptions) {
      sub.cancel();
    }
    _watchSubscriptions.clear();
    _watchDebounceTimer?.cancel();

    if (!settingsVM!.isFolderWatcherEnabled) {
      log('INDEXER: Folder watcher is disabled in settings.');
      return;
    }

    for (final folderPath in settingsVM!.monitoredFolders) {
      _watchFolder(folderPath, folderType: 0);
    }

    for (final folderPath in settingsVM!.audiobookFolders) {
      _watchFolder(folderPath, folderType: 1);
    }
  }

  void _watchFolder(String path, {required int folderType}) {
    final dir = Directory(path);
    if (!dir.existsSync()) return;

    log('INDEXER: Starting filesystem watcher on: $path');
    try {
      late StreamSubscription<FileSystemEvent> sub;
      sub = dir.watch(recursive: true).listen((event) {
        log('INDEXER: Detected FS change in $path: ${event.type} on ${event.path}');
        _triggerDebouncedScan();
      }, onError: (Object e) {
        log('INDEXER: FS Watcher error on $path: $e');
        sub.cancel();
        _watchSubscriptions.remove(sub);
      }, onDone: () {
        log('INDEXER: FS Watcher closed on $path');
        sub.cancel();
        _watchSubscriptions.remove(sub);
      });
      _watchSubscriptions.add(sub);
    } catch (e) {
      log('INDEXER: Failed to start FS Watcher on $path: $e');
    }
  }

  void _triggerDebouncedScan() {
    if (settingsVM == null || libService == null) return;
    _watchDebounceTimer?.cancel();
    _watchDebounceTimer = Timer(const Duration(seconds: 3), () {
      if (currentState() == IndexerState.idle) {
        log('INDEXER: Debounce timer fired. Running background library scan.');
        unawaited(scanLibrary(settingsVM!.monitoredFolders, libService!, folderType: 0).then((_) {
          if (settingsVM!.audiobookFolders.isNotEmpty) {
            unawaited(scanLibrary(settingsVM!.audiobookFolders, libService!, folderType: 1));
          }
        }));
      } else {
        log('INDEXER: Library indexer is busy (${currentState().name}), deferring background scan.');
        _watchDebounceTimer = Timer(const Duration(seconds: 5), _triggerDebouncedScan);
      }
    });
  }

  void dispose() {
    settingsVM?.removeListener(onSettingsChanged);
    for (var sub in _watchSubscriptions) {
      sub.cancel();
    }
    _watchSubscriptions.clear();
    _watchDebounceTimer?.cancel();
  }
}
