import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localaudioplayer/data/library/local_library_service.dart';
import 'package:audiotags/audiotags.dart' as tags;
import 'dart:typed_data';
import 'package:platform/platform.dart';

import 'package:on_audio_query_pluse/on_audio_query.dart';

import 'package:localaudioplayer/domain/core/permission_service.dart';

class MockAudioTagsWrapper extends Mock implements AudioTagsWrapper {}

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

class MockPlatform extends Mock implements Platform {}

class MockPermissionService extends Mock implements PermissionService {}

class MockTag extends Mock implements tags.Tag {
  @override
  List<tags.Picture> get pictures => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryFileSystem fileSystem;
  late MockAudioTagsWrapper mockTags;
  late MockOnAudioQuery mockAudioQuery;
  late MockPlatform mockPlatform;
  late MockPermissionService mockPermissions;
  late LocalLibraryService service;

  setUpAll(() {
    registerFallbackValue(ArtworkType.AUDIO);
    registerFallbackValue(ArtworkFormat.JPEG);
  });

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockTags = MockAudioTagsWrapper();
    mockAudioQuery = MockOnAudioQuery();
    mockPlatform = MockPlatform();
    mockPermissions = MockPermissionService();

    // Default to Android for testing discovery logic
    when(() => mockPlatform.isAndroid).thenReturn(true);
    when(() => mockPlatform.isIOS).thenReturn(false);
    when(
      () => mockPermissions.requestAudioPermission(),
    ).thenAnswer((_) async => true);

    service = LocalLibraryService(
      fileSystem: fileSystem,
      tagsWrapper: mockTags,
      audioQuery: mockAudioQuery,
      permissions: mockPermissions,
      platform: mockPlatform,
    );
  });

  group('LocalLibraryService', () {
    test(
      'should scan directory and return audio files with metadata',
      () async {
        // Arrange
        final dir = fileSystem.directory('/music')..createSync();
        dir.childFile('song1.mp3').createSync();
        dir.childFile('song2.mp3').createSync();
        dir.childFile('not_audio.txt').createSync();

        final tag1 = MockTag();
        when(() => tag1.title).thenReturn('Title 1');
        when(() => tag1.trackArtist).thenReturn('Artist 1');
        when(() => tag1.album).thenReturn('Album 1');
        when(() => tag1.duration).thenReturn(120);

        final tag2 = MockTag();
        when(() => tag2.title).thenReturn('Title 2');
        when(() => tag2.trackArtist).thenReturn('Artist 2');
        when(() => tag2.album).thenReturn('Album 2');
        when(() => tag2.duration).thenReturn(180);

        when(() => mockTags.read(any())).thenAnswer((invocation) async {
          final path = invocation.positionalArguments[0] as String;
          if (path.contains('song1')) {
            return tag1;
          } else {
            return tag2;
          }
        });

        // Act
        final result = await service.scanDirectory('/music');

        // Assert
        expect(result.length, 2);
        expect(result[0].title, 'Title 1');
        expect(result[1].title, 'Title 2');
        expect(result[0].path, '/music/song1.mp3');
        expect(result[1].path, '/music/song2.mp3');
        expect(result[0].duration, const Duration(seconds: 120));
      },
    );

    test('should return empty list if directory does not exist', () async {
      final result = await service.scanDirectory('/non_existent');
      expect(result, isEmpty);
    });

    test(
      'discoverTracks should return songs from MediaStore with high-fidelity metadata',
      () async {
        // SongModel doesn't have a public factory for arbitrary maps easily without seeing internal structure
        // But we can mock it
        final mockSong = MockSongModel();
        when(() => mockSong.data).thenReturn('/storage/music/song1.mp3');
        when(() => mockSong.title).thenReturn('MediaStore Title');
        when(() => mockSong.artist).thenReturn('MediaStore Artist');
        when(() => mockSong.album).thenReturn('MediaStore Album');
        when(() => mockSong.genre).thenReturn('Rock');
        when(() => mockSong.duration).thenReturn(200000);
        when(() => mockSong.id).thenReturn(123);
        when(() => mockSong.getMap).thenReturn({'year': 2024});

        when(
          () => mockAudioQuery.permissionsStatus(),
        ).thenAnswer((_) async => true);
        when(
          () => mockAudioQuery.querySongs(
            sortType: any(named: 'sortType'),
            orderType: any(named: 'orderType'),
            uriType: any(named: 'uriType'),
            ignoreCase: any(named: 'ignoreCase'),
          ),
        ).thenAnswer((_) async => [mockSong]);

        final dummyArtwork = Uint8List.fromList([1, 2, 3]);
        when(
          () => mockAudioQuery.queryArtwork(
            any(),
            any(),
            format: any(named: 'format'),
            size: any(named: 'size'),
          ),
        ).thenAnswer((_) async => dummyArtwork);

        final result = await service.discoverTracks();

        expect(result.length, 1);
        expect(result[0].title, 'MediaStore Title');
        expect(result[0].genre, 'Rock');
        expect(result[0].year, 2024);
        expect(result[0].coverArt, dummyArtwork);
      },
    );
  });
}

class MockSongModel extends Mock implements SongModel {}
