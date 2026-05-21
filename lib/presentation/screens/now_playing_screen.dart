import 'package:flutter/material.dart' hide RepeatMode;
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/features/library/screens/insights_screen.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:provider/provider.dart';

import 'widgets/now_playing/now_playing_controls.dart';
import 'widgets/now_playing/now_playing_progress.dart';
import 'widgets/now_playing/now_playing_volume.dart';
import 'widgets/now_playing/now_playing_content.dart';

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
                        child: _buildMainPlayer(playerVM, theme, constraints, isCompact),
                      ),
                    ),
                    _buildSectionHeader(theme, playerVM),
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(40, 24, 40, 120),
                      sliver: NowPlayingContent(),
                    ),
                  ],
                ),
              ),
              _buildInsightsGrabBar(theme, primaryColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainPlayer(PlayerViewModel vm, ThemeData theme, BoxConstraints constraints, bool isCompact) {
    final double artSize = (constraints.maxHeight * 0.45).clamp(180.0, isCompact ? 400.0 : 500.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        _buildAlbumArtWithControls(vm, theme, artSize, isCompact),
        const SizedBox(height: 32),
        _buildTrackInfo(theme, vm, isCompact),
        if (!isCompact) ...[
          const SizedBox(height: 24),
          const NowPlayingProgress(),
          const SizedBox(height: 16),
          const NowPlayingControls(),
          const SizedBox(height: 24),
          const NowPlayingVolume(),
        ],
        const SizedBox(height: 40),
        Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface.withValues(alpha: 0.1), size: 24),
      ],
    );
  }

  Widget _buildAlbumArtWithControls(PlayerViewModel vm, ThemeData theme, double size, bool isCompact) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: 'now_playing_art',
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                image: vm.currentTrack?.coverArt != null
                    ? DecorationImage(image: MemoryImage(vm.currentTrack!.coverArt!), fit: BoxFit.cover)
                    : vm.currentImageUrl != null
                        ? DecorationImage(image: NetworkImage(vm.currentImageUrl!), fit: BoxFit.cover)
                        : null,
              ),
              child: vm.currentTrack?.coverArt == null && vm.currentImageUrl == null
                  ? const Icon(Icons.music_note, size: 80, color: Colors.white10)
                  : null,
            ),
          ),
        ),
        if (isCompact)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: Colors.black45),
              child: const NowPlayingControls(isOverlay: true),
            ),
          ),
      ],
    );
  }

  Widget _buildTrackInfo(ThemeData theme, PlayerViewModel vm, bool isCompact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(vm.displayTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isCompact ? 22 : 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(vm.currentArtistName,
              style: TextStyle(color: theme.colorScheme.primary, fontSize: isCompact ? 14 : 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, PlayerViewModel vm) {
    final type = vm.currentMediaType;
    String label = 'UP NEXT';
    if (type == MediaType.podcast) label = 'SHOW NOTES';
    if (type == MediaType.radio) label = 'STATION INFO';
    if (type == MediaType.audiobook) label = 'CHAPTERS';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10)),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Colors.white10),
        ]),
      ),
    );
  }

  Widget _buildInsightsGrabBar(ThemeData theme, Color primary) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          key: const Key('insights_grab_bar'),
          onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          child: Container(
            width: 24,
            height: 100,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: Icon(Icons.insights, size: 16, color: primary.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(ThemeData theme, PlayerViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary.withValues(alpha: 0.1), theme.colorScheme.surface],
        ),
      ),
    );
  }
}
