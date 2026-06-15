import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class AudiobookClipsPane extends StatelessWidget {
  final Album book;
  const AudiobookClipsPane({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);

    return StreamBuilder<List<Bookmark>>(
      stream: playerVM.watchAudiobookClips(book.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final clips = snapshot.data!;

        if (clips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                const Text('No clips for this book.', style: TextStyle(fontSize: 12, color: Colors.white24)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: clips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final clip = clips[index];
            return InkWell(
              onTap: () => playerVM.playBookmark(clip),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clip.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      _formatMs(clip.startTimeMs),
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
