import 'package:aulos/data/database/app_database.dart';
import 'smart_playlist_rule.dart';

class SmartPlaylistEngine {
  static List<Track> generateQueue(
    List<Track> allTracks,
    SmartPlaylistConfig config, {
    Map<String, String> artistNames = const {},
    Map<String, String> albumNames = const {},
    Map<String, String> genreNames = const {},
  }) {
    final filtered = allTracks.where((track) {
      return evaluateTrack(
        track,
        config,
        artistNames: artistNames,
        albumNames: albumNames,
        genreNames: genreNames,
      );
    }).toList();

    // Default sorting / ordering
    filtered.sort((a, b) {
      if (a.lastPlayed != null && b.lastPlayed != null) {
        return b.lastPlayed!.compareTo(a.lastPlayed!);
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    if (config.limit != null && config.limit! > 0) {
      return filtered.take(config.limit!).toList();
    }
    return filtered;
  }

  static bool evaluateTrack(
    Track track,
    SmartPlaylistConfig config, {
    Map<String, String> artistNames = const {},
    Map<String, String> albumNames = const {},
    Map<String, String> genreNames = const {},
  }) {
    if (config.rules.isEmpty) return true;

    if (config.matchAll) {
      return config.rules.every((rule) => _evaluateRule(
            track,
            rule,
            artistNames: artistNames,
            albumNames: albumNames,
            genreNames: genreNames,
          ));
    } else {
      return config.rules.any((rule) => _evaluateRule(
            track,
            rule,
            artistNames: artistNames,
            albumNames: albumNames,
            genreNames: genreNames,
          ));
    }
  }

  static bool _evaluateRule(
    Track track,
    SmartPlaylistRule rule, {
    required Map<String, String> artistNames,
    required Map<String, String> albumNames,
    required Map<String, String> genreNames,
  }) {
    final fieldValue = _getFieldValue(
      track,
      rule.field,
      artistNames: artistNames,
      albumNames: albumNames,
      genreNames: genreNames,
    );

    if (fieldValue == null) {
      if (rule.operator == RuleOperator.isFalse) return true;
      if (rule.operator == RuleOperator.isTrue) return false;
      return false;
    }

    switch (rule.operator) {
      case RuleOperator.equals:
        return fieldValue.toString().toLowerCase() == rule.value.toLowerCase();
      case RuleOperator.notEquals:
        return fieldValue.toString().toLowerCase() != rule.value.toLowerCase();
      case RuleOperator.contains:
        return fieldValue.toString().toLowerCase().contains(rule.value.toLowerCase());
      case RuleOperator.greaterThan:
        final numVal = num.tryParse(fieldValue.toString());
        final ruleVal = num.tryParse(rule.value);
        if (numVal == null || ruleVal == null) return false;
        return numVal > ruleVal;
      case RuleOperator.lessThan:
        final numVal = num.tryParse(fieldValue.toString());
        final ruleVal = num.tryParse(rule.value);
        if (numVal == null || ruleVal == null) return false;
        return numVal < ruleVal;
      case RuleOperator.isTrue:
        return fieldValue == true || fieldValue.toString().toLowerCase() == 'true';
      case RuleOperator.isFalse:
        return fieldValue == false || fieldValue.toString().toLowerCase() == 'false';
      case RuleOperator.before:
        DateTime? dt;
        if (fieldValue is DateTime) {
          dt = fieldValue;
        } else {
          dt = DateTime.tryParse(fieldValue.toString());
        }
        if (dt == null) return false;
        final ruleDate = DateTime.tryParse(rule.value);
        if (ruleDate == null) return false;
        return dt.isBefore(ruleDate);
      case RuleOperator.after:
        DateTime? dt;
        if (fieldValue is DateTime) {
          dt = fieldValue;
        } else {
          dt = DateTime.tryParse(fieldValue.toString());
        }
        if (dt == null) return false;
        final ruleDate = DateTime.tryParse(rule.value);
        if (ruleDate == null) return false;
        return dt.isAfter(ruleDate);
    }
  }

  static dynamic _getFieldValue(
    Track track,
    RuleField field, {
    required Map<String, String> artistNames,
    required Map<String, String> albumNames,
    required Map<String, String> genreNames,
  }) {
    switch (field) {
      case RuleField.title:
        return track.title;
      case RuleField.artist:
        return artistNames[track.artistId] ?? track.artistId;
      case RuleField.album:
        return albumNames[track.albumId] ?? track.albumId;
      case RuleField.genre:
        return genreNames[track.genreId] ?? track.genreId;
      case RuleField.year:
        return track.year;
      case RuleField.rating:
        return track.rating;
      case RuleField.playCount:
        return track.playCount;
      case RuleField.isFavorite:
        return track.isFavorite;
      case RuleField.lastPlayed:
        return track.lastPlayed;
      case RuleField.durationSeconds:
        return track.durationSeconds;
    }
  }
}
