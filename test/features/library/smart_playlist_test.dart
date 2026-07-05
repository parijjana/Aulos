import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/library/smart_playlist_rule.dart';
import 'package:aulos/domain/library/smart_playlist_engine.dart';

void main() {
  group('Smart Playlist Engine Tests', () {
    final track1 = Track(
      id: '1',
      path: '/path/1.mp3',
      title: 'Rock Anthem',
      artistId: 'artist-rock',
      albumId: 'album-classic',
      genreId: 'genre-rock',
      year: 1995,
      durationSeconds: 240,
      folderId: 'folder-1',
      rating: 5,
      isFavorite: true,
      playCount: 12,
      lastPlayed: DateTime(2026, 6, 1),
      isAudiobook: false,
      isPlayed: false,
    );

    final track2 = Track(
      id: '2',
      path: '/path/2.mp3',
      title: 'Pop Love',
      artistId: 'artist-pop',
      albumId: 'album-hits',
      genreId: 'genre-pop',
      year: 2020,
      durationSeconds: 180,
      folderId: 'folder-1',
      rating: 3,
      isFavorite: false,
      playCount: 5,
      lastPlayed: DateTime(2026, 5, 15),
      isAudiobook: false,
      isPlayed: false,
    );

    final track3 = Track(
      id: '3',
      path: '/path/3.mp3',
      title: 'Heavy Metal Blast',
      artistId: 'artist-metal',
      albumId: 'album-thunder',
      genreId: 'genre-metal',
      year: 1999,
      durationSeconds: 300,
      folderId: 'folder-1',
      rating: 5,
      isFavorite: true,
      playCount: 20,
      lastPlayed: DateTime(2026, 6, 15),
      isAudiobook: false,
      isPlayed: false,
    );

    final List<Track> allTracks = [track1, track2, track3];
    final artistNames = {
      'artist-rock': 'The Rockers',
      'artist-pop': 'Pop Star',
      'artist-metal': 'Metal Heads',
    };
    final albumNames = {
      'album-classic': 'Rock Classics',
      'album-hits': 'Pop Hits 2020',
      'album-thunder': 'Thunder Power',
    };
    final genreNames = {
      'genre-rock': 'Rock',
      'genre-pop': 'Pop',
      'genre-metal': 'Metal',
    };

    test('Filter by Favorite tracks only', () {
      final config = SmartPlaylistConfig(
        rules: [
          SmartPlaylistRule(
            field: RuleField.isFavorite,
            operator: RuleOperator.isTrue,
            value: '',
          )
        ],
      );

      final result = SmartPlaylistEngine.generateQueue(
        allTracks,
        config,
        artistNames: artistNames,
        albumNames: albumNames,
        genreNames: genreNames,
      );

      expect(result.length, 2);
      expect(result.any((t) => t.title == 'Rock Anthem'), true);
      expect(result.any((t) => t.title == 'Heavy Metal Blast'), true);
      expect(result.any((t) => t.title == 'Pop Love'), false);
    });

    test('Filter by Rating > 4 and genre contains Rock', () {
      final config = SmartPlaylistConfig(
        rules: [
          SmartPlaylistRule(
            field: RuleField.rating,
            operator: RuleOperator.greaterThan,
            value: '4',
          ),
          SmartPlaylistRule(
            field: RuleField.genre,
            operator: RuleOperator.contains,
            value: 'Rock',
          )
        ],
        matchAll: true,
      );

      final result = SmartPlaylistEngine.generateQueue(
        allTracks,
        config,
        artistNames: artistNames,
        albumNames: albumNames,
        genreNames: genreNames,
      );

      expect(result.length, 1);
      expect(result.first.title, 'Rock Anthem');
    });

    test('Filter with OR matchAll: false (Rating > 4 OR year < 2000)', () {
      final config = SmartPlaylistConfig(
        rules: [
          SmartPlaylistRule(
            field: RuleField.rating,
            operator: RuleOperator.greaterThan,
            value: '4',
          ),
          SmartPlaylistRule(
            field: RuleField.year,
            operator: RuleOperator.lessThan,
            value: '2000',
          )
        ],
        matchAll: false,
      );

      final result = SmartPlaylistEngine.generateQueue(
        allTracks,
        config,
        artistNames: artistNames,
        albumNames: albumNames,
        genreNames: genreNames,
      );

      // track1: rating 5, year 1995 -> matches both
      // track2: rating 3, year 2020 -> matches none
      // track3: rating 5, year 1999 -> matches both
      expect(result.length, 2);
      expect(result.any((t) => t.title == 'Rock Anthem'), true);
      expect(result.any((t) => t.title == 'Heavy Metal Blast'), true);
    });

    test('Limit results', () {
      final config = SmartPlaylistConfig(
        rules: [
          SmartPlaylistRule(
            field: RuleField.playCount,
            operator: RuleOperator.greaterThan,
            value: '0',
          )
        ],
        limit: 1,
      );

      final result = SmartPlaylistEngine.generateQueue(
        allTracks,
        config,
        artistNames: artistNames,
        albumNames: albumNames,
        genreNames: genreNames,
      );

      expect(result.length, 1);
    });
  });
}
