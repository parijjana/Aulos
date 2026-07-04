import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/features/visualizer/widgets/winamp_visualizer.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/features/library/screens/insights_screen.dart';
import 'package:aulos/presentation/screens/widgets/now_playing/strategies/now_playing_strategy.dart';
import 'package:aulos/presentation/screens/widgets/now_playing/strategies/music_strategy.dart';
import 'package:aulos/presentation/screens/widgets/now_playing/strategies/audiobook_strategy.dart';
import 'package:aulos/presentation/screens/widgets/now_playing/strategies/podcast_strategy.dart';
import 'package:aulos/presentation/screens/widgets/now_playing/strategies/radio_strategy.dart';
import 'package:aulos/presentation/screens/widgets/now_playing/strategies/noise_strategy.dart';
import 'package:provider/provider.dart';
import 'widgets/sleep_timer_dialog.dart';

import 'widgets/now_playing/now_playing_controls.dart';
import 'widgets/now_playing/now_playing_progress.dart';
import 'widgets/now_playing/now_playing_volume.dart';
import 'widgets/now_playing/now_playing_content.dart';
import 'widgets/now_playing/now_playing_background.dart';
import 'widgets/now_playing/now_playing_insights_grab_bar.dart';
import 'widgets/now_playing/now_playing_track_info.dart';
import 'widgets/now_playing/now_playing_artwork.dart';

class NowPlayingScreen extends StatefulWidget {
  final bool isTabbed;

  const NowPlayingScreen({super.key, this.isTabbed = false});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  NowPlayingStrategy _getStrategy(MediaType type) {
    switch (type) {
      case MediaType.music: return MusicStrategy();
      case MediaType.audiobook: return AudiobookStrategy();
      case MediaType.podcast: return PodcastStrategy();
      case MediaType.radio: return RadioStrategy();
      case MediaType.noise: return NoiseStrategy();
    }
  }

  String _formatSleepTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playerVM = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);
    final settingsVM = context.watch<SettingsViewModel>();
    final bool isDynamic = settingsVM.isDynamicTheme;
    Color primaryColor = theme.colorScheme.primary;
    if (isDynamic && playerVM.extractedColor != null) {
      primaryColor = playerVM.extractedColor!;
    }

    final strategy = _getStrategy(playerVM.currentMediaType);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: widget.isTabbed ? Colors.transparent : theme.colorScheme.surface,
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
        child: const InsightsScreen(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxHeight < 550 || constraints.maxWidth < 400;
          final bool useArtworkOverlay = constraints.maxHeight < 550;

          return Stack(
            children: [
              NowPlayingBackground(vm: playerVM),
              Scrollbar(
                controller: _scrollController,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is OverscrollNotification && notification.overscroll < 0) {
                      ScrollToDashboardNotification().dispatch(context);
                      return true;
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildMainPlayer(playerVM, theme, constraints, isCompact, useArtworkOverlay, strategy),
                      ),
                    ),
                    _buildSectionHeader(theme, strategy),
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(40, 24, 40, 120),
                      sliver: NowPlayingContent(),
                    ),
                  ],
                  ),
                ),
              ),
              NowPlayingInsightsGrabBar(
                primaryColor: primaryColor,
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainPlayer(PlayerViewModel vm, ThemeData theme, BoxConstraints constraints, bool isCompact, bool useArtworkOverlay, NowPlayingStrategy strategy) {
    final settingsVM = context.read<SettingsViewModel>();
    final double artSize = (constraints.maxHeight * 0.45).clamp(140.0, isCompact ? 400.0 : 500.0);
    
    // Hide headers if constraints.maxHeight is extremely small (e.g. < 300) to avoid vertical overflow
    final bool showHeader = constraints.maxHeight >= 300 && constraints.maxWidth >= 240;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showHeader) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.grid_view_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                tooltip: 'Mood Dashboard',
                onPressed: () {
                  ScrollToDashboardNotification().dispatch(context);
                },
              ),
              Text(
                'NOW PLAYING',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      (vm.isSleepTimerActive == true) ? Icons.snooze_rounded : Icons.timer_outlined,
                      color: (vm.isSleepTimerActive == true) ? Colors.amber : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    tooltip: 'Sleep Timer',
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => const SleepTimerDialog(),
                      );
                    },
                  ),
                  if (vm.isSleepTimerActive == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatSleepTime(vm.sleepTimeRemaining),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        NowPlayingArtwork(
          vm: vm,
          size: artSize,
          isCompact: useArtworkOverlay,
          strategy: strategy,
        ),
        if (constraints.maxHeight >= 220) ...[
          const SizedBox(height: 16),
          NowPlayingTrackInfo(vm: vm, isCompact: isCompact),
        ],
        if (!useArtworkOverlay) ...[
          if (!isCompact && (settingsVM.isVisualizerEnabled == true) && vm.currentMediaType == MediaType.music) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
child: WinampVisualizer(pluginId: settingsVM.visualizerPluginId),
            ),
          ],
          const SizedBox(height: 24),
          if (strategy.showProgress) const NowPlayingProgress(),
          const SizedBox(height: 16),
          const NowPlayingControls(),
          const SizedBox(height: 24),
          const NowPlayingVolume(),
        ],
        if (showHeader) ...[
          const SizedBox(height: 20),
          Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface.withValues(alpha: 0.1), size: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, NowPlayingStrategy strategy) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(strategy.sectionLabel, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10)),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.white10),
        ]),
      ),
    );
  }
}

class ScrollToDashboardNotification extends Notification {
  ScrollToDashboardNotification();
}
