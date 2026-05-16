import 'package:flutter/material.dart' hide RepeatMode;
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as domain;
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

class NowPlayingScreen extends StatefulWidget {
  final bool isTabbed;

  const NowPlayingScreen({super.key, this.isTabbed = false});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerVM = context.watch<PlayerViewModel>();
    final queueVM = context.watch<QueueViewModel>();
    final connectivityVM = context.watch<ConnectivityViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.isTabbed
          ? Colors.transparent
          : theme.colorScheme.surface,
      body: Stack(
        children: [
          if (!widget.isTabbed) _buildBackground(theme, playerVM),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          if (queueVM.history.isNotEmpty) ...[
                            _buildHistoryHeader(queueVM, theme),
                            _buildHistoryList(playerVM, queueVM, theme),
                          ],
                          SliverToBoxAdapter(
                            child: _buildNowPlayingSection(
                              context,
                              theme,
                              playerVM,
                            ),
                          ),
                          _buildQueueHeader(queueVM, theme),
                          _buildQueueList(playerVM, queueVM, theme),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!widget.isTabbed &&
                    (playerVM.isRemoteMode || playerVM.isHostMode))
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.link_off_rounded,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      onPressed: connectivityVM.disconnect,
                      tooltip: playerVM.isHostMode
                          ? 'Stop Hosting'
                          : 'Disconnect from Host',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader(QueueViewModel queueVM, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
        child: Row(
          children: [
            Text(
              'HISTORY',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    PlayerViewModel playerVM,
    QueueViewModel queueVM,
    ThemeData theme,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final track = queueVM.history[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: ListTile(
            leading: _buildMiniArt(
              track.coverArt,
              false,
              theme,
              isHistory: true,
            ),
            title: Text(
              track.title,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
            subtitle: Text(
              'Recently Played',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                fontSize: 10,
              ),
            ),
            onTap: () async {
              await playerVM.loadTrack(track);
            },
          ),
        );
      }, childCount: queueVM.history.length),
    );
  }

  Widget _buildNowPlayingSection(
    BuildContext context,
    ThemeData theme,
    PlayerViewModel playerVM,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double artSize = 300.0;
        final double horizontalPadding = constraints.maxWidth > 800
            ? constraints.maxWidth * 0.2
            : 40.0;

        return Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAlbumArt(playerVM, artSize),
              const SizedBox(height: 40),
              _buildTrackInfo(theme, playerVM, horizontalPadding),
              _buildProgressBar(theme, playerVM, horizontalPadding),
              const SizedBox(height: 8),
              _buildVolumeSection(theme, playerVM, horizontalPadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVolumeSection(
    ThemeData theme,
    PlayerViewModel vm,
    double padding,
  ) {
    final onBackground = theme.colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding + 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: vm.isShuffle
                  ? theme.colorScheme.primary
                  : onBackground.withValues(alpha: 0.3),
              size: 20,
            ),
            onPressed: vm.toggleShuffle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                activeTrackColor: theme.colorScheme.primary.withValues(
                  alpha: 0.6,
                ),
                inactiveTrackColor: onBackground.withValues(alpha: 0.1),
                thumbColor: theme.colorScheme.primary,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(value: vm.volume, onChanged: vm.setVolume),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              vm.repeatMode == domain.RepeatMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              color: vm.repeatMode != domain.RepeatMode.off
                  ? theme.colorScheme.primary
                  : onBackground.withValues(alpha: 0.3),
              size: 20,
            ),
            onPressed: vm.toggleRepeat,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueHeader(QueueViewModel queueVM, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UP NEXT',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Row(
              children: [
                Text(
                  '${queueVM.currentQueue.length} TRACKS',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: 0.38,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: queueVM.clearQueue,
                  icon: const Icon(
                    Icons.clear_all,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  label: const Text(
                    'CLEAR',
                    style: TextStyle(color: Colors.redAccent, fontSize: 10),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueList(
    PlayerViewModel playerVM,
    QueueViewModel queueVM,
    ThemeData theme,
  ) {
    return SliverReorderableList(
      itemCount: queueVM.currentQueue.length,
      onReorder: queueVM.moveTrack,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: GlassCard(
          opacity: 0.2,
          blur: 10,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
      itemBuilder: (context, index) {
        final track = queueVM.currentQueue[index];
        final isPlaying = queueVM.currentIndex == index;
        final onBackground = theme.colorScheme.onSurface;

        return Dismissible(
          key: ValueKey('dismiss_queue_item_${track.id}_$index'),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 40),
            color: Colors.redAccent.withValues(alpha: 0.2),
            child: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
          onDismissed: (direction) {
            queueVM.removeFromQueue(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ListTile(
              leading: _buildMiniArt(track.coverArt, isPlaying, theme),
              title: Text(
                track.title,
                style: TextStyle(
                  color: isPlaying ? theme.colorScheme.primary : onBackground,
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                isPlaying ? playerVM.currentArtistName : 'Unknown Artist',
                style: TextStyle(color: onBackground.withValues(alpha: 0.38)),
              ),
              trailing: ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: onBackground.withValues(alpha: 0.24),
                ),
              ),
              onTap: () => playerVM.playTrackAtIndex(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniArt(
    Uint8List? art,
    bool isPlaying,
    ThemeData theme, {
    bool isHistory = false,
  }) {
    if (isPlaying) {
      return Icon(
        Icons.play_circle_filled,
        color: theme.colorScheme.primary,
        size: 40,
      );
    }
    return Opacity(
      opacity: isHistory ? 0.5 : 1.0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          image: art != null
              ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
              : null,
        ),
        child: art == null
            ? Icon(
                Icons.music_note,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildBackground(ThemeData theme, PlayerViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.surface,
            theme.colorScheme.secondary.withValues(alpha: 0.1) ??
                theme.colorScheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(PlayerViewModel vm, double size) {
    final art = vm.currentTrack?.coverArt;
    return Center(
      child: Hero(
        tag: 'album_art',
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(48),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              image: art != null
                  ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
                  : null,
              gradient: art == null
                  ? LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: art == null
                ? Icon(
                    Icons.music_note,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.2),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(ThemeData theme, PlayerViewModel vm, double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.displayTitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    overflow: TextOverflow.ellipsis,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.currentArtistName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildRatingButtons(context, theme, vm),
        ],
      ),
    );
  }

  Widget _buildRatingButtons(
    BuildContext context,
    ThemeData theme,
    PlayerViewModel vm,
  ) {
    final queueVM = context.read<QueueViewModel>();
    final track = vm.currentTrack;
    final rating = track?.rating ?? 0;
    final onBackground = theme.colorScheme.onSurface;

    return Row(
      children: [
        IconButton(
          icon: Icon(
            rating == 1 ? Icons.favorite : Icons.favorite_border,
            color: rating == 1
                ? Colors.pinkAccent
                : onBackground.withValues(alpha: 0.3),
            size: 28,
          ),
          onPressed: () {
            if (track != null) {
              queueVM.updateRating(track.id, rating == 1 ? 0 : 1);
            }
          },
        ),
        IconButton(
          icon: Icon(
            rating == -1 ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
            color: rating == -1
                ? Colors.orangeAccent
                : onBackground.withValues(alpha: 0.3),
            size: 28,
          ),
          onPressed: () {
            if (track != null) {
              queueVM.updateRating(track.id, rating == -1 ? 0 : -1);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    ThemeData theme,
    PlayerViewModel vm,
    double padding,
  ) {
    final pos = vm.position;
    final dur = vm.duration;
    final progress = dur.inMilliseconds > 0
        ? pos.inMilliseconds / dur.inMilliseconds
        : 0.0;
    final onBackground = theme.colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding - 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: onBackground.withValues(alpha: 0.05),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                vm.seek(
                  Duration(milliseconds: (v * dur.inMilliseconds).toInt()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(pos),
                  style: TextStyle(
                    color: onBackground.withValues(alpha: 0.38),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDuration(dur),
                  style: TextStyle(
                    color: onBackground.withValues(alpha: 0.38),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
