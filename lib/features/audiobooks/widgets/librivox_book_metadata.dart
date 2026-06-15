import 'package:flutter/material.dart';
import 'package:aulos/domain/library/librivox_book.dart';

class LibriVoxBookMetadata extends StatelessWidget {
  final LibriVoxBook book;
  final bool isDownloaded;
  final bool isStreaming;

  const LibriVoxBookMetadata({
    super.key,
    required this.book,
    required this.isDownloaded,
    required this.isStreaming,
  });

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'Unknown duration';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          'By ${book.authorNames}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (book.narrators.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Narrated by: ${book.narrators.join(", ")}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(book.totalTimeSecs),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language_rounded, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  book.language,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isDownloaded)
          _buildStatusChip(Colors.teal, Icons.download_done_rounded, 'Downloaded')
        else if (isStreaming)
          _buildStatusChip(Colors.orange, Icons.sensors_rounded, 'Streaming Available')
        else
          _buildStatusChip(theme.colorScheme.primary, Icons.public_rounded, 'Public Domain'),
      ],
    );
  }

  Widget _buildStatusChip(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
