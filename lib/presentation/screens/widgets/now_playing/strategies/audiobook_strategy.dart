import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:provider/provider.dart';
import 'now_playing_strategy.dart';
import '../now_playing_controls.dart';

class AudiobookStrategy extends NowPlayingStrategy {
  @override
  String get sectionLabel => 'CHAPTERS';

  @override
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize, {bool isOverlay = false}) {
    final width = MediaQuery.of(context).size.width;
    final showSecondary = width > 500 && !isOverlay;
    final showSkips = width > 340;
    final showReplays = width > 200;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSecondary) ...[
            buildSpeedSelector(vm, theme, isOverlay: isOverlay),
            const SizedBox(width: 16),
          ],
          if (showSkips) ...[
            buildCircularButton(Icons.skip_previous_rounded, vm.skipPrevious, buttonSize * 0.9, theme, isOverlay: isOverlay),
            const SizedBox(width: 12),
          ],
          if (showReplays) ...[
            buildCircularButton(Icons.replay_10_rounded, vm.skipBackward, buttonSize, theme, isOverlay: isOverlay),
            const SizedBox(width: 16),
          ],
          buildAulosPlayButton(vm, theme, primarySize),
          if (showReplays) ...[
            const SizedBox(width: 16),
            buildCircularButton(Icons.forward_10_rounded, vm.skipForward, buttonSize, theme, isOverlay: isOverlay),
          ],
          if (showSkips) ...[
            const SizedBox(width: 12),
            buildCircularButton(Icons.skip_next_rounded, vm.skipNext, buttonSize * 0.9, theme, isOverlay: isOverlay),
          ],
          if (showSecondary) ...[
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
              isOverlay: isOverlay,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, PlayerViewModel vm, ThemeData theme) {
    final currentTrack = vm.currentTrack;
    final queueVM = context.watch<QueueViewModel>();
    final chapters = vm.currentChapters;

    return StreamBuilder<List<Bookmark>>(
      stream: currentTrack != null 
          ? vm.watchAudiobookBookmarksForTrack(currentTrack.path)
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
                              ? _ChapterMarkersList(
                                  chapters: chapters,
                                  playerVM: vm,
                                  theme: theme,
                                )
                              : _ChaptersList(
                                  queueVM: queueVM,
                                  playerVM: vm,
                                  theme: theme,
                                ),
                            _ClipsList(
                              clips: clips,
                              playerVM: vm,
                              theme: theme,
                            ),
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
                        ? _ChapterMarkersList(
                            chapters: chapters,
                            playerVM: vm,
                            theme: theme,
                          )
                        : _ChaptersList(
                            queueVM: queueVM,
                            playerVM: vm,
                            theme: theme,
                          ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2, 
                    child: _ClipsList(
                      clips: clips,
                      playerVM: vm,
                      theme: theme,
                    ),
                  ),
                ],
              );
            }

            return _ChaptersList(
              queueVM: queueVM,
              playerVM: vm,
              theme: theme,
            );
          },
        );
      },
    );
  }
}

class _ChapterMarkersList extends StatelessWidget {
  final List<AudiobookChapter> chapters;
  final PlayerViewModel playerVM;
  final ThemeData theme;

  const _ChapterMarkersList({
    required this.chapters,
    required this.playerVM,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ChaptersList extends StatelessWidget {
  final QueueViewModel queueVM;
  final PlayerViewModel playerVM;
  final ThemeData theme;

  const _ChaptersList({
    required this.queueVM,
    required this.playerVM,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ClipsList extends StatelessWidget {
  final List<Bookmark> clips;
  final PlayerViewModel playerVM;
  final ThemeData theme;

  const _ClipsList({
    required this.clips,
    required this.playerVM,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
}

String _formatMs(int ms) {
  final d = Duration(milliseconds: ms);
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
