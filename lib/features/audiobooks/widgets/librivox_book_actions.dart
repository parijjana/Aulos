import 'package:flutter/material.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';

class LibriVoxBookActions extends StatelessWidget {
  final LibriVoxBook book;
  final bool isDownloaded;
  final bool isStreaming;
  final double? progress;
  final LibriVoxViewModel vm;
  final LibraryViewModel libraryVM;
  final PlayerViewModel playerVM;

  const LibriVoxBookActions({
    super.key,
    required this.book,
    required this.isDownloaded,
    required this.isStreaming,
    required this.progress,
    required this.vm,
    required this.libraryVM,
    required this.playerVM,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (progress != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Downloading archive...',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
              ),
              Text(
                '${(progress! * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            color: theme.colorScheme.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    }

    if (isDownloaded) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play'),
          onPressed: () async {
            final album = libraryVM.findBookByLibrivoxId(book.id);
            if (album == null) return;
            final tracks = await libraryVM.getTracksForItem(album);
            if (tracks.isNotEmpty) {
              playerVM.setQueueAndPlay(tracks, 0);
            }
          },
        ),
      );
    }

    // Book is not downloaded: show Row with Play (Stream) and Download/Download & Play buttons
    return Row(
      children: [
        // Play (Stream) Button
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.sensors_rounded),
            label: const Text('Play (Stream)'),
            onPressed: () async {
              if (!isStreaming) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preparing stream for "${book.title}"...')),
                );
                await vm.streamBook(book);
                await libraryVM.reloadLibrary();
              }
              if (!context.mounted) return;
              final album = libraryVM.findBookByLibrivoxId(book.id);
              if (album != null) {
                final tracks = await libraryVM.getTracksForItem(album);
                if (tracks.isNotEmpty) {
                  playerVM.setQueueAndPlay(tracks, 0);
                }
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        // Download / Download & Play Button
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.download_rounded),
            label: Text(isStreaming ? 'Download' : 'Download & Play'),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading "${book.title}"...')),
              );
              await vm.downloadBook(book);
              await libraryVM.reloadLibrary();
              if (!context.mounted) return;
              final album = libraryVM.findBookByLibrivoxId(book.id);
              if (album != null) {
                final tracks = await libraryVM.getTracksForItem(album);
                if (tracks.isNotEmpty) {
                  playerVM.setQueueAndPlay(tracks, 0);
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
