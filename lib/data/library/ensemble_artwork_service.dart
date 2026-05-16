import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:localaudioplayer/data/library/artwork_service.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class EnsembleArtworkService {
  final ArtworkService _artworkService;

  EnsembleArtworkService({required ArtworkService artworkService})
      : _artworkService = artworkService;

  /// Regex to identify multiple artists.
  /// Matches common separators: , & ; feat. ft. and
  static final RegExp _artistSeparator = RegExp(
    r'\s*(?:,|&|;|feat\.?|ft\.?|(?<=\s)and(?=\s))\s*',
    caseSensitive: false,
  );

  /// Splits an ensemble artist name into individual artists.
  List<String> splitArtists(String ensembleName) {
    final parts = ensembleName.split(_artistSeparator);
    return parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// Checks if a name represents multiple artists.
  bool isEnsemble(String name) {
    return _artistSeparator.hasMatch(name);
  }

  /// Fetches individual artworks and stitches them into a grid.
  Future<Uint8List?> createEnsembleArtwork(
    String ensembleName, {
    String? localFolder,
  }) async {
    final artists = splitArtists(ensembleName);
    if (artists.length <= 1) return null;

    // Limit to top 4 for a 2x2 grid
    final artistsToFetch = artists.take(4).toList();
    final List<Uint8List> artistImages = [];

    final ensembleArtworkDir = localFolder != null 
        ? Directory(p.join(localFolder, '.artwork', 'ensemble_${ensembleName.hashCode}'))
        : null;

    if (ensembleArtworkDir != null && !ensembleArtworkDir.existsSync()) {
      await ensembleArtworkDir.create(recursive: true);
    }

    for (final artist in artistsToFetch) {
      // Fetch each artist's photo
      // Note: fetchArtistPhoto handles its own caching/local saving if localFolder is provided.
      // But we want to save individual ones in the ensemble subfolder for clarity if requested.
      final imageBytes = await _artworkService.fetchArtistPhoto(
        artist,
        localFolder: ensembleArtworkDir?.path,
      );

      if (imageBytes != null) {
        artistImages.add(imageBytes);
      }
    }

    if (artistImages.isEmpty) return null;
    if (artistImages.length == 1) return artistImages.first;

    return _stitchImages(artistImages);
  }

  Uint8List? _stitchImages(List<Uint8List> images) {
    try {
      final decodedImages = images
          .map((bytes) => img.decodeImage(bytes))
          .whereType<img.Image>()
          .toList();

      if (decodedImages.isEmpty) return null;

      const int targetSize = 600; // Final image size
      final canvas = img.Image(width: targetSize, height: targetSize);

      if (decodedImages.length == 2) {
        // Side by side
        final left = img.copyResize(
          decodedImages[0],
          width: targetSize ~/ 2,
          height: targetSize,
          interpolation: img.Interpolation.linear,
        );
        final right = img.copyResize(
          decodedImages[1],
          width: targetSize ~/ 2,
          height: targetSize,
          interpolation: img.Interpolation.linear,
        );
        img.compositeImage(canvas, left, dstX: 0, dstY: 0);
        img.compositeImage(canvas, right, dstX: targetSize ~/ 2, dstY: 0);
      } else if (decodedImages.length == 3) {
        // One top, two bottom
        final top = img.copyResize(
          decodedImages[0],
          width: targetSize,
          height: targetSize ~/ 2,
          interpolation: img.Interpolation.linear,
        );
        final bottomL = img.copyResize(
          decodedImages[1],
          width: targetSize ~/ 2,
          height: targetSize ~/ 2,
          interpolation: img.Interpolation.linear,
        );
        final bottomR = img.copyResize(
          decodedImages[2],
          width: targetSize ~/ 2,
          height: targetSize ~/ 2,
          interpolation: img.Interpolation.linear,
        );
        img.compositeImage(canvas, top, dstX: 0, dstY: 0);
        img.compositeImage(canvas, bottomL, dstX: 0, dstY: targetSize ~/ 2);
        img.compositeImage(canvas, bottomR, dstX: targetSize ~/ 2, dstY: targetSize ~/ 2);
      } else {
        // 2x2 grid
        final cellSize = targetSize ~/ 2;
        for (int i = 0; i < decodedImages.length && i < 4; i++) {
          final cell = img.copyResize(
            decodedImages[i],
            width: cellSize,
            height: cellSize,
            interpolation: img.Interpolation.linear,
          );
          final x = (i % 2) * cellSize;
          final y = (i ~/ 2) * cellSize;
          img.compositeImage(canvas, cell, dstX: x, dstY: y);
        }
      }

      return Uint8List.fromList(img.encodeJpg(canvas));
    } catch (e) {
      print('EnsembleArtworkService: Stitching failed: $e');
      return null;
    }
  }
}
