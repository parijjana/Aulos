import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class BookmarksView extends StatelessWidget {
  final String trackPath;

  const BookmarksView({super.key, required this.trackPath});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);

    return FutureBuilder<List<Bookmark>>(
      future: db.getBookmarksForTrack(trackPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final bookmarks = snapshot.data!;

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_outline, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Text('No bookmarks for this track', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          itemBuilder: (context, index) {
            final b = bookmarks[index];
            return ListTile(
              dense: true,
              leading: const Icon(Icons.play_circle_outline, size: 24),
              title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                '${_formatDuration(Duration(milliseconds: b.startTimeMs))} - ${_formatDuration(Duration(milliseconds: b.endTimeMs ?? 0))}',
                style: const TextStyle(fontSize: 10),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => db.deleteBookmark(b.id),
              ),
              onTap: () => playerVM.playBookmark(b),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
