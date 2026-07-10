import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/storage_cache_view_model.dart';

class StorageCacheManagerWidget extends StatelessWidget {
  const StorageCacheManagerWidget({super.key});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int suffixIndex = 0;
    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    return Consumer<StorageCacheViewModel>(
      builder: (context, storageVM, child) {
        final totalSizeStr = _formatBytes(storageVM.totalSize);
        final podcastSizeStr = _formatBytes(storageVM.podcastSize);
        final audiobookSizeStr = _formatBytes(storageVM.audiobookSize);

        return GlassCard(
          title: 'OFFLINE CACHE MANAGER',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Offline Downloads',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: onSurface.withValues(alpha: 0.5),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalSizeStr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: storageVM.isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primary,
                              ),
                            )
                          : Icon(
                              Icons.refresh_outlined,
                              color: onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                      onPressed: storageVM.isLoading
                          ? null
                          : () => storageVM.refreshSizes(),
                      tooltip: 'Refresh Storage Sizes',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Audiobooks row
                _StorageItemRow(
                  title: 'Audiobooks Folder',
                  sizeString: audiobookSizeStr,
                  icon: Icons.book_online_outlined,
                  onOpen: () => storageVM.openAudiobookFolder(),
                  theme: theme,
                  onSurface: onSurface,
                ),
                const SizedBox(height: 12),
                
                // Podcasts row
                _StorageItemRow(
                  title: 'Podcasts Folder',
                  sizeString: podcastSizeStr,
                  icon: Icons.podcasts_outlined,
                  onOpen: () => storageVM.openPodcastFolder(),
                  theme: theme,
                  onSurface: onSurface,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StorageItemRow extends StatelessWidget {
  final String title;
  final String sizeString;
  final IconData icon;
  final VoidCallback onOpen;
  final ThemeData theme;
  final Color onSurface;

  const _StorageItemRow({
    required this.title,
    required this.sizeString,
    required this.icon,
    required this.onOpen,
    required this.theme,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sizeString,
                  style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.folder_open_outlined, size: 14),
            label: const Text(
              'OPEN FOLDER',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: onSurface.withValues(alpha: 0.8),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
