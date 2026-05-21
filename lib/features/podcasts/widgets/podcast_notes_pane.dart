import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/html_text.dart';
import 'package:provider/provider.dart';

class PodcastNotesPane extends StatelessWidget {
  final Episode? selectedEpisode;
  final Function(Episode) onTogglePin;
  final Function(Episode) onPlay;

  const PodcastNotesPane({
    super.key,
    this.selectedEpisode,
    required this.onTogglePin,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerVM = context.read<PlayerViewModel>();

    if (selectedEpisode == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            const SizedBox(height: 16),
            Text('Select an episode to view notes', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.24))),
          ],
        ),
      );
    }

    final ep = selectedEpisode!;
    return Column(
      children: [
        _buildNotesHeader(ep, theme),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            key: PageStorageKey('podcast_notes_scroll_${ep.id}'),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ep.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 8),
                Text(
                  ep.pubDate?.toString().split(' ')[0] ?? 'Unknown Date',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 32),
                HtmlText(
                  ep.description ?? 'No notes available.',
                  onTimestampTap: (duration) => playerVM.seek(duration),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesHeader(Episode ep, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(ep.isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: ep.isPinned ? theme.colorScheme.primary : null),
            onPressed: () => onTogglePin(ep),
            tooltip: ep.isPinned ? 'Unpin' : 'Pin',
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => onPlay(ep),
            icon: const Icon(Icons.play_arrow),
            label: const Text('PLAY EPISODE'),
          ),
        ],
      ),
    );
  }
}
