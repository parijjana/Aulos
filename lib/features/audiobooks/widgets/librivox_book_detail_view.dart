import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'librivox_book_cover.dart';
import 'librivox_book_metadata.dart';
import 'librivox_book_actions.dart';

class LibriVoxBookDetailView extends StatelessWidget {
  final LibriVoxBook book;
  final VoidCallback? onBack;

  const LibriVoxBookDetailView({
    super.key,
    required this.book,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<LibriVoxViewModel>();
    final libraryVM = context.read<LibraryViewModel>();
    final playerVM = context.read<PlayerViewModel>();

    final libraryAlbum = libraryVM.findBookByLibrivoxId(book.id);
    final bool isDownloaded = libraryAlbum?.isDownloadedViaAulos ?? false;
    final bool isStreaming = libraryAlbum != null && !libraryAlbum.isDownloadedViaAulos;
    final double? progress = vm.downloadProgress[book.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Back Button if provided
          if (onBack != null)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBack,
                  tooltip: 'Back to Storefront',
                ),
                Text(
                  'Book Details',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'BOOK DETAILS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Cover and Metadata Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibriVoxBookCover(book: book),
              const SizedBox(width: 16),
              Expanded(
                child: LibriVoxBookMetadata(
                  book: book,
                  isDownloaded: isDownloaded,
                  isStreaming: isStreaming,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          const Text(
            'DESCRIPTION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: SingleChildScrollView(
              child: Text(
                book.description.isNotEmpty
                    ? book.description
                    : 'No description available for this public domain audiobook.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons or progress
          LibriVoxBookActions(
            book: book,
            isDownloaded: isDownloaded,
            isStreaming: isStreaming,
            progress: progress,
            vm: vm,
            libraryVM: libraryVM,
            playerVM: playerVM,
          ),
        ],
      ),
    );
  }
}
