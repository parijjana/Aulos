import 'package:aulos/data/database/radio_database.dart';
import 'package:drift/drift.dart';

/// In-place mutation helpers for the browse/search result lists held by
/// RadioViewModel. These update a station's health/favorite/pin/hidden
/// flag by index so the UI reflects a change immediately without waiting
/// for the DB write (and can roll back on failure) or re-sorting the list.
class RadioStationListUpdater {
  static void updateAvailability(
    List<RadioStation> browseResults,
    List<RadioStation> searchResults,
    String uuid,
    bool available,
  ) {
    final now = DateTime.now();

    final bIndex = browseResults.indexWhere((s) => s.stationUuid == uuid);
    if (bIndex != -1) {
      browseResults[bIndex] = browseResults[bIndex].copyWith(
        isAvailable: available,
        lastCheck: Value(now),
      );
    }

    final sIndex = searchResults.indexWhere((s) => s.stationUuid == uuid);
    if (sIndex != -1) {
      searchResults[sIndex] = searchResults[sIndex].copyWith(
        isAvailable: available,
        lastCheck: Value(now),
      );
    }
  }

  static bool updateFavorite(
    List<RadioStation> browseResults,
    List<RadioStation> searchResults,
    String uuid,
    bool isFavorite,
  ) {
    bool changed = false;
    for (int i = 0; i < browseResults.length; i++) {
      if (browseResults[i].stationUuid == uuid) {
        browseResults[i] = browseResults[i].copyWith(isFavorite: isFavorite);
        changed = true;
      }
    }
    for (int i = 0; i < searchResults.length; i++) {
      if (searchResults[i].stationUuid == uuid) {
        searchResults[i] = searchResults[i].copyWith(isFavorite: isFavorite);
        changed = true;
      }
    }
    return changed;
  }

  static bool updatePinned(
    List<RadioStation> browseResults,
    List<RadioStation> searchResults,
    String uuid,
    bool isPinned,
  ) {
    bool changed = false;
    for (int i = 0; i < browseResults.length; i++) {
      if (browseResults[i].stationUuid == uuid) {
        browseResults[i] = browseResults[i].copyWith(isPinned: isPinned);
        changed = true;
      }
    }
    for (int i = 0; i < searchResults.length; i++) {
      if (searchResults[i].stationUuid == uuid) {
        searchResults[i] = searchResults[i].copyWith(isPinned: isPinned);
        changed = true;
      }
    }
    return changed;
  }

  static bool updateHidden(
    List<RadioStation> browseResults,
    List<RadioStation> searchResults,
    String uuid,
    bool isHidden,
  ) {
    bool changed = false;
    for (int i = 0; i < browseResults.length; i++) {
      if (browseResults[i].stationUuid == uuid) {
        browseResults[i] = browseResults[i].copyWith(isHidden: isHidden);
        changed = true;
      }
    }
    for (int i = 0; i < searchResults.length; i++) {
      if (searchResults[i].stationUuid == uuid) {
        searchResults[i] = searchResults[i].copyWith(isHidden: isHidden);
        changed = true;
      }
    }
    return changed;
  }
}
