import 'package:flutter/material.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class AudiobookBookmarksSidebar extends StatelessWidget {
  const AudiobookBookmarksSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);
    final currentTrack = playerVM.currentTrack;

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.98),
        border: Border(left: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidebarHeader(theme: theme),
          Expanded(
            child: _ClipsStreamBuilder(
              playerVM: playerVM,
              currentTrack: currentTrack,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final ThemeData theme;
  const _SidebarHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 16),
      child: Row(
        children: [
          Icon(Icons.book_rounded, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            'BOOK CLIPS',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipsStreamBuilder extends StatelessWidget {
  final PlayerViewModel playerVM;
  final dynamic currentTrack;
  final ThemeData theme;

  const _ClipsStreamBuilder({
    required this.playerVM,
    required this.currentTrack,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Bookmark>>(
      stream: currentTrack != null 
          ? playerVM.watchBookmarksForTrack(currentTrack.path as String)
          : Stream.value([]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final bookmarks = snapshot.data!;

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border_rounded, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                const SizedBox(height: 16),
                Text('No clips for this book.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.24), fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final b = bookmarks[index];
            return _BookmarkCard(bookmark: b, playerVM: playerVM, theme: theme);
          },
        );
      },
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final PlayerViewModel playerVM;
  final ThemeData theme;

  const _BookmarkCard({required this.bookmark, required this.playerVM, required this.theme});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => playerVM.playBookmark(bookmark),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookmarkCardHeader(bookmark: bookmark, playerVM: playerVM),
            if (bookmark.tags != null && bookmark.tags!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _BookmarkCardTags(tagsString: bookmark.tags!, theme: theme),
            ],
            const SizedBox(height: 12),
            _BookmarkCardFooter(bookmark: bookmark, theme: theme),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCardHeader extends StatelessWidget {
  final Bookmark bookmark;
  final PlayerViewModel playerVM;

  const _BookmarkCardHeader({required this.bookmark, required this.playerVM});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            bookmark.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 14),
          onPressed: () => playerVM.deleteBookmark(bookmark.id),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _BookmarkCardTags extends StatelessWidget {
  final String tagsString;
  final ThemeData theme;

  const _BookmarkCardTags({required this.tagsString, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tagsString.split(',').map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(t.trim().toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      )).toList(),
    );
  }
}

class _BookmarkCardFooter extends StatelessWidget {
  final Bookmark bookmark;
  final ThemeData theme;

  const _BookmarkCardFooter({required this.bookmark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.play_circle_outline, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          _formatMs(bookmark.startTimeMs),
          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          '${_formatMs((bookmark.endTimeMs ?? 0) - bookmark.startTimeMs)} CLIP',
          style: TextStyle(fontSize: 8, color: theme.colorScheme.primary.withValues(alpha: 0.5), fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ],
    );
  }

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
