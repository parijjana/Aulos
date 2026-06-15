import 'package:flutter/foundation.dart';
import 'package:aulos/data/library/librivox_service.dart';
import 'package:aulos/data/library/librivox_book_downloader.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LibriVoxViewModel extends ChangeNotifier {
  final LibriVoxService _service;
  final LibriVoxBookDownloader _downloader;
  final LogService _logService;

  List<LibriVoxBook> _searchResults = [];
  final Map<String, List<LibriVoxBook>> _categoryResults = {};
  final Map<String, bool> _categoryLoading = {};
  String _filterQuery = '';
  bool _isLoading = false;
  String? _error;
  final Map<String, double> _downloadProgress = {};
  LibriVoxBook? _selectedBook;
  String _lastSearchQuery = '';
  bool _disposed = false;

  LibriVoxViewModel({
    required LibriVoxService service,
    required LibriVoxBookDownloader downloader,
    LogService? logService,
  }) : _service = service,
       _downloader = downloader,
       _logService = logService ?? NoOpLogService();

  void log(String message) => _logService.log(message);

  List<LibriVoxBook> get searchResults => _searchResults;
  Map<String, List<LibriVoxBook>> get categoryResults => _categoryResults;
  Map<String, bool> get categoryLoading => _categoryLoading;
  String get filterQuery => _filterQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, double> get downloadProgress => _downloadProgress;
  LibriVoxBook? get selectedBook => _selectedBook;
  String get lastSearchQuery => _lastSearchQuery;

  List<LibriVoxBook> get filteredResults {
    if (_filterQuery.isEmpty) {
      return _searchResults;
    }
    final query = _filterQuery.toLowerCase();
    return _searchResults.where((book) {
      final matchesTitle = book.title.toLowerCase().contains(query);
      final matchesAuthor = book.authors.any((a) =>
          a.firstName.toLowerCase().contains(query) ||
          a.lastName.toLowerCase().contains(query) ||
          a.fullName.toLowerCase().contains(query));
      final matchesNarrator = book.narrators.any((n) => n.toLowerCase().contains(query));
      return matchesTitle || matchesAuthor || matchesNarrator;
    }).toList();
  }

  void selectBook(LibriVoxBook? book) {
    _selectedBook = book;
    notifyListeners();
  }

  void setFilterQuery(String query) {
    _filterQuery = query;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _isLoading = true;
    _error = null;
    _lastSearchQuery = query;
    _filterQuery = ''; // Reset local filter on new remote search
    notifyListeners();

    try {
      _searchResults = await _service.searchBooks(query);
    } catch (e) {
      _error = e.toString();
      log('LIBRIVOX_VM: Search failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategoryPreviews(List<Map<String, dynamic>> categories, {bool force = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString('last_librivox_sync_time');
      final cachedPreviewsJson = prefs.getString('cached_librivox_category_previews');
      
      bool needsSync = force || lastSyncStr == null || cachedPreviewsJson == null;
      if (!needsSync) {
        final lastSync = DateTime.tryParse(lastSyncStr!);
        if (lastSync == null || DateTime.now().difference(lastSync).inDays >= 30) {
          needsSync = true;
        }
      }

      if (!needsSync) {
        log('LIBRIVOX_VM: Loading category previews from local cache...');
        final Map<String, dynamic> decoded = jsonDecode(cachedPreviewsJson!) as Map<String, dynamic>;
        decoded.forEach((key, listJson) {
          final list = listJson as List;
          _categoryResults[key] = list.map((item) => LibriVoxBook.fromJson(item as Map<String, dynamic>)).toList();
        });
        
        // Seed _searchResults with Featured Classics ('')
        _searchResults = _categoryResults[''] ?? [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      log('LIBRIVOX_VM: Fetching category previews from remote API...');
      // 1. Load Featured Classics (empty query)
      _searchResults = await _service.searchBooks('');
      _categoryResults[''] = _searchResults;
      _isLoading = false;
      notifyListeners();

      // 2. Load other categories asynchronously
      for (var cat in categories) {
        final query = cat['query'] as String;
        if (query.isNotEmpty) {
          _categoryLoading[query] = true;
          notifyListeners();
          
          try {
            final results = await _service.searchBooks(query);
            _categoryResults[query] = results;
          } catch (e) {
            log('LIBRIVOX_VM: Category "$query" load failed: $e');
          } finally {
            _categoryLoading[query] = false;
            notifyListeners();
          }
        }
      }

      // Serialize and save to SharedPreferences
      final Map<String, dynamic> toSerialize = {};
      _categoryResults.forEach((key, list) {
        toSerialize[key] = list.map((b) => b.toJson()).toList();
      });
      await prefs.setString('cached_librivox_category_previews', jsonEncode(toSerialize));
      await prefs.setString('last_librivox_sync_time', DateTime.now().toIso8601String());
    } catch (e) {
      _error = e.toString();
      log('LIBRIVOX_VM: Error loading category previews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> streamBook(LibriVoxBook book) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _downloader.streamBook(book);
    } catch (e) {
      log('LIBRIVOX_VM: Stream integration failed: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadBook(LibriVoxBook book) async {
    if (_downloadProgress.containsKey(book.id)) return; // already downloading
    _downloadProgress[book.id] = 0.0;
    notifyListeners();

    try {
      await _downloader.downloadBook(
        book,
        onProgress: (progress) {
          _downloadProgress[book.id] = progress;
          notifyListeners();
        },
      );
    } catch (e) {
      log('LIBRIVOX_VM: Download failed: $e');
      _error = e.toString();
    } finally {
      _downloadProgress.remove(book.id);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
