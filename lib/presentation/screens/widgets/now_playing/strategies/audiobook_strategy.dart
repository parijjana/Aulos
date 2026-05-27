import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:provider/provider.dart';
import 'now_playing_strategy.dart';
import '../now_playing_controls.dart';

class AudiobookStrategy extends NowPlayingStrategy {
  @override
  String get sectionLabel => 'CHAPTERS';

  @override
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildSpeedSelector(vm, theme),
          const SizedBox(width: 16),
          buildCircularButton(Icons.skip_previous_rounded, vm.skipPrevious, buttonSize * 0.9, theme),
          const SizedBox(width: 12),
          buildCircularButton(Icons.replay_10_rounded, vm.skipBackward, buttonSize, theme),
          const SizedBox(width: 16),
          buildAulosPlayButton(vm, theme, primarySize),
          const SizedBox(width: 16),
          buildCircularButton(Icons.forward_10_rounded, vm.skipForward, buttonSize, theme),
          const SizedBox(width: 12),
          buildCircularButton(Icons.skip_next_rounded, vm.skipNext, buttonSize * 0.9, theme),
          const SizedBox(width: 16),
          buildCircularButton(
            vm.isBookmarkMode ? Icons.check_circle : Icons.bookmark_add_outlined, 
            () {
              if (vm.isBookmarkMode) {
                showRichBookmarkDialog(context, vm, theme);
              } else {
                vm.toggleBookmark();
              }
            }, 
            buttonSize, 
            theme,
            color: vm.isBookmarkMode ? theme.colorScheme.primary : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, PlayerViewModel vm, ThemeData theme) {
    final db = context.read<AppDatabase>();
    final currentTrack = vm.currentTrack;
    final queueVM = context.watch<QueueViewModel>();
    final chapters = vm.currentChapters;

    return StreamBuilder<List<Bookmark>>(
      stream: currentTrack != null 
          ? (db.select(db.bookmarks)..where((t) => t.trackPath.equals(currentTrack.path) & t.contextType.equals(2))).watch()
          : Stream.value([]),
      builder: (context, snapshot) {
        final clips = snapshot.data ?? [];
        final bool hasClips = clips.isNotEmpty;
        final bool hasChapters = chapters.isNotEmpty;

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 600;

            if (hasClips || hasChapters) {
              if (isNarrow) {
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                        tabs: const [Tab(text: 'CHAPTERS'), Tab(text: 'CLIPS')],
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            hasChapters 
                              ? _buildChapterMarkersList(chapters, vm, theme)
                              : _buildChaptersList(queueVM, vm, theme),
                            _buildClipsList(clips, vm, theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3, 
                    child: hasChapters 
                        ? _buildChapterMarkersList(chapters, vm, theme)
                        : _buildChaptersList(queueVM, vm, theme)
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(flex: 2, child: _buildClipsList(clips, vm, theme)),
                ],
              );
            }

            return _buildChaptersList(queueVM, vm, theme);
          },
        );
      },
    );
  }

  Widget _buildChapterMarkersList(List<Chapter> chapters, PlayerViewModel playerVM, ThemeData theme) {
    final currentPos = playerVM.position.inMilliseconds;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final isPlaying = currentPos >= chapter.startTimeMs && 
                         (index == chapters.length - 1 || currentPos < chapters[index+1].startTimeMs);
        
        return ListTile(
          dense: true,
          leading: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPlaying ? theme.colorScheme.primary : Colors.white10,
            ),
            child: Center(
              child: isPlaying 
                ? const Icon(Icons.play_arrow, size: 12, color: Colors.white)
                : Text('${index + 1}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
          title: Text(
            chapter.title, 
            style: TextStyle(
              color: isPlaying ? theme.colorScheme.primary : null, 
              fontWeight: isPlaying ? FontWeight.bold : null, 
              fontSize: 13
            )
          ),
          subtitle: Text(_formatMs(chapter.startTimeMs), style: const TextStyle(fontSize: 10)),
          onTap: () => playerVM.seek(Duration(milliseconds: chapter.startTimeMs)),
        );
      },
    );
  }

  Widget _buildChaptersList(QueueViewModel queueVM, PlayerViewModel playerVM, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: queueVM.currentQueue.length,
      itemBuilder: (context, index) {
        final track = queueVM.currentQueue[index];
        final isPlaying = queueVM.currentIndex == index;
        return ListTile(
          dense: true,
          leading: buildMiniArt(context, track.coverArt, isPlaying, theme),
          title: Text(track.title, style: TextStyle(color: isPlaying ? theme.colorScheme.primary : null, fontWeight: isPlaying ? FontWeight.bold : null, fontSize: 13)),
          onTap: () => playerVM.playTrackAtIndex(index),
        );
      },
    );
  }

  Widget _buildClipsList(List<Bookmark> clips, PlayerViewModel playerVM, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clips.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final clip = clips[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(clip.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          subtitle: Text(_formatMs(clip.startTimeMs), style: TextStyle(fontSize: 10, color: theme.colorScheme.primary)),
          onTap: () => playerVM.playBookmark(clip),
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
