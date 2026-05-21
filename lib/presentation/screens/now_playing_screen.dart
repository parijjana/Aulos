import 'package:flutter/material.dart' hide RepeatMode;
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/screens/widgets/html_text.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as domain;
import 'package:provider/provider.dart';
import 'dart:typed_data';

class NowPlayingScreen extends StatefulWidget {
  final bool isTabbed;

  const NowPlayingScreen({super.key, this.isTabbed = false});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playerVM = context.watch<PlayerViewModel>();
    final queueVM = context.watch<QueueViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.isTabbed ? Colors.transparent : theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.maxHeight;
          final double w = constraints.maxWidth;
          
          // isCompact: The "overlay" mode for short or narrow windows
          final bool isCompact = h < 550 || w < 400;

          return Stack(
            children: [
              if (!widget.isTabbed) _buildBackground(theme, playerVM),
              
              Scrollbar(
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildResponsiveMainPlayer(playerVM, theme, queueVM, constraints, isCompact),
                      ),
                    ),
                    
                    SliverToBoxAdapter(child: _buildDynamicMetadataHeader(playerVM, theme)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(40, 24, 40, 120),
                      sliver: _buildSliverContent(context, playerVM, queueVM, theme),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsiveMainPlayer(PlayerViewModel vm, ThemeData theme, QueueViewModel queueVM, BoxConstraints constraints, bool isCompact) {
    // Dynamic art size: larger on big screens, constrained on small ones
    final double maxArt = isCompact ? 400.0 : 500.0;
    final double artSize = (constraints.maxHeight * 0.45).clamp(180.0, maxArt);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildAlbumArt(vm, artSize),
            if (isCompact)
               Positioned.fill(
                 child: Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(40),
                     color: Colors.black45,
                   ),
                   child: _buildContextualControls(theme, vm, queueVM, isOverlay: true),
                 ),
               ),
          ],
        ),
        const SizedBox(height: 32),
        _buildTrackInfo(theme, vm, isCompact: isCompact),
        if (!isCompact) ...[
          const SizedBox(height: 24),
          _buildProgressBar(theme, vm),
          const SizedBox(height: 16),
          _buildContextualControls(theme, vm, queueVM, isOverlay: false),
          const SizedBox(height: 24),
          _buildVolumeSection(theme, vm),
        ],
        const SizedBox(height: 40),
        Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface.withValues(alpha: 0.1), size: 24),
      ],
    );
  }

  Widget _buildContextualControls(ThemeData theme, PlayerViewModel vm, QueueViewModel queueVM, {bool isOverlay = false}) {
    final mediaType = vm.currentMediaType;
    final double buttonSize = isOverlay ? 36 : 48;
    final double primaryButtonSize = isOverlay ? 72 : 96;

    // 1. RADIO: Play/Stop Only
    if (mediaType == MediaType.radio) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: vm.isPlaying ? vm.stop : vm.play,
            padding: EdgeInsets.zero,
            icon: Container(
              width: primaryButtonSize,
              height: primaryButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                ),
              ),
              child: Icon(
                vm.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: primaryButtonSize * 0.5,
              ),
            ),
          ),
        ],
      );
    }

    // 2. PODCAST / AUDIOBOOK: Speed, -10, Play/Pause, +15, Bookmark
    if (mediaType == MediaType.podcast || mediaType == MediaType.audiobook) {
      final bool isAudiobook = mediaType == MediaType.audiobook;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpeedSelector(vm, theme, isOverlay),
            const SizedBox(width: 16),
            if (isAudiobook) ...[
              _buildCircularButton(
                icon: Icons.skip_previous_rounded,
                onPressed: vm.skipPrevious,
                size: buttonSize * 0.9,
                theme: theme,
                isOverlay: isOverlay,
              ),
              const SizedBox(width: 12),
            ],
            _buildCircularButton(
              icon: Icons.replay_10_rounded,
              onPressed: vm.skipBackward,
              size: buttonSize,
              theme: theme,
              isOverlay: isOverlay,
            ),
            const SizedBox(width: 16),
            _buildAulosPlayButton(vm, theme, size: primaryButtonSize),
            const SizedBox(width: 16),
            _buildCircularButton(
              icon: Icons.forward_10_rounded, // fallback to 10
              onPressed: vm.skipForward,
              size: buttonSize,
              theme: theme,
              isOverlay: isOverlay,
            ),
            if (isAudiobook) ...[
              const SizedBox(width: 12),
              _buildCircularButton(
                icon: Icons.skip_next_rounded,
                onPressed: vm.skipNext,
                size: buttonSize * 0.9,
                theme: theme,
                isOverlay: isOverlay,
              ),
            ],
            const SizedBox(width: 16),
            _buildCircularButton(
              icon: Icons.bookmark_add_outlined,
              onPressed: vm.bookmark,
              size: buttonSize,
              theme: theme,
              isOverlay: isOverlay,
            ),
          ],
        ),
      );
    }

    // 3. MUSIC: Favorite, Shuffle, Prev, Play/Pause, Next, Repeat, Dislike
    final currentTrack = vm.currentTrack;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (currentTrack != null) ...[
            IconButton(
              icon: Icon(
                currentTrack.rating == -1 ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                color: currentTrack.rating == -1 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              onPressed: () => queueVM.updateRating(currentTrack.id, -1),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: Icon(
              vm.isShuffle ? Icons.shuffle : Icons.shuffle_rounded,
              color: vm.isShuffle ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            onPressed: vm.toggleShuffle,
          ),
          const SizedBox(width: 8),
          _buildCircularButton(
            icon: Icons.skip_previous_rounded,
            onPressed: vm.skipPrevious,
            size: buttonSize,
            theme: theme,
            isOverlay: isOverlay,
          ),
          const SizedBox(width: 16),
          _buildAulosPlayButton(vm, theme, size: primaryButtonSize),
          const SizedBox(width: 16),
          _buildCircularButton(
            icon: Icons.skip_next_rounded,
            onPressed: vm.skipNext,
            size: buttonSize,
            theme: theme,
            isOverlay: isOverlay,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              vm.repeatMode == domain.RepeatMode.one ? Icons.repeat_one : Icons.repeat,
              color: vm.repeatMode != domain.RepeatMode.off ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            onPressed: vm.toggleRepeat,
          ),
          if (currentTrack != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                currentTrack.rating == 1 ? Icons.favorite : Icons.favorite_border,
                color: currentTrack.rating == 1 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              onPressed: () => queueVM.updateRating(currentTrack.id, 1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAulosPlayButton(PlayerViewModel vm, ThemeData theme, {double size = 88}) {
    final primary = theme.colorScheme.primary;
    return IconButton(
      onPressed: vm.isPlaying ? vm.pause : vm.play,
      padding: EdgeInsets.zero,
      icon: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, primary.withValues(alpha: 0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          vm.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon, 
    required VoidCallback onPressed, 
    required double size, 
    required ThemeData theme,
    bool isOverlay = false,
  }) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOverlay ? Colors.white10 : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          border: Border.all(color: isOverlay ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: isOverlay ? Colors.white : theme.colorScheme.onSurface, size: size * 0.5),
      ),
    );
  }

  Widget _buildSpeedSelector(PlayerViewModel vm, ThemeData theme, bool isOverlay) {
    return PopupMenuButton<double>(
      initialValue: vm.playbackSpeed,
      onSelected: vm.setSpeed,
      itemBuilder: (context) => [0.5, 0.8, 1.0, 1.2, 1.5, 2.0].map((s) => PopupMenuItem(
        value: s,
        child: Text('${s}x', style: TextStyle(fontWeight: vm.playbackSpeed == s ? FontWeight.bold : FontWeight.normal)),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isOverlay ? Colors.black45 : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isOverlay ? Colors.white24 : theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${vm.playbackSpeed}x', style: TextStyle(color: isOverlay ? Colors.white : theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 10)),
            Icon(Icons.arrow_drop_down, color: isOverlay ? Colors.white : theme.colorScheme.primary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicMetadataHeader(PlayerViewModel playerVM, ThemeData theme) {
    final mediaType = playerVM.currentMediaType;
    String title = 'UP NEXT';
    if (mediaType == MediaType.podcast) title = 'SHOW NOTES';
    if (mediaType == MediaType.radio) title = 'STATION INFO';
    if (mediaType == MediaType.audiobook) title = 'CHAPTERS';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildSliverContent(BuildContext context, PlayerViewModel playerVM, QueueViewModel queueVM, ThemeData theme) {
    final mediaType = playerVM.currentMediaType;

    if (mediaType == MediaType.podcast) {
      return SliverToBoxAdapter(
        child: HtmlText(
          playerVM.currentShowNotes ?? 'No notes available.',
          onTimestampTap: (d) => playerVM.seek(d),
        ),
      );
    }

    if (mediaType == MediaType.radio) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.radio, size: 48, color: Colors.white10),
              const SizedBox(height: 16),
              Text(
                playerVM.currentStreamMetadata ?? 'Live Stream: ${playerVM.displayTitle}', 
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Internet Radio',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final track = queueVM.currentQueue[index];
          final isPlaying = queueVM.currentIndex == index;
          return ListTile(
            dense: true,
            leading: _buildMiniArt(track.coverArt, isPlaying, theme),
            title: Text(track.title, style: TextStyle(color: isPlaying ? theme.colorScheme.primary : null, fontWeight: isPlaying ? FontWeight.bold : null)),
            subtitle: Text(track.path, style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => playerVM.playTrackAtIndex(index),
          );
        },
        childCount: queueVM.currentQueue.length,
      ),
    );
  }

  Widget _buildTrackInfo(ThemeData theme, PlayerViewModel vm, {bool isCompact = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            vm.displayTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isCompact ? 22 : 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            vm.currentArtistName,
            style: TextStyle(color: theme.colorScheme.primary, fontSize: isCompact ? 14 : 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(PlayerViewModel vm, double size) {
    final art = vm.currentTrack?.coverArt;
    final imageUrl = vm.currentImageUrl;
    
    return Hero(
      tag: 'now_playing_art',
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            image: art != null && art.isNotEmpty 
                ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
                : imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    : null,
          ),
          child: (art == null || art.isEmpty) && (imageUrl == null || imageUrl.isEmpty) 
              ? const Icon(Icons.music_note, size: 80, color: Colors.white10) 
              : null,
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, PlayerViewModel vm) {
    final pos = vm.position;
    final dur = vm.duration;
    final progress = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              thumbColor: theme.colorScheme.primary,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final newPos = Duration(milliseconds: (v * dur.inMilliseconds).toInt());
                vm.seek(newPos);
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(pos), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 11, fontWeight: FontWeight.bold)),
              Text(_formatDuration(dur), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSection(ThemeData theme, PlayerViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.volume_down, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        SizedBox(
          width: 200,
          child: Slider(
            value: vm.volume,
            onChanged: vm.setVolume,
            activeColor: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        Icon(Icons.volume_up, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildMiniArt(Uint8List? art, bool isPlaying, ThemeData theme) {
    if (isPlaying) return Icon(Icons.play_circle_filled, color: theme.colorScheme.primary, size: 32);
    final imageUrl = context.read<PlayerViewModel>().currentImageUrl;

    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        image: art != null && art.isNotEmpty 
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                : null,
      ),
      child: (art == null || art.isEmpty) && (imageUrl == null || imageUrl.isEmpty) 
          ? const Icon(Icons.music_note, size: 16, color: Colors.white10) 
          : null,
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Widget _buildBackground(ThemeData theme, PlayerViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.surface,
          ],
        ),
      ),
    );
  }
}
