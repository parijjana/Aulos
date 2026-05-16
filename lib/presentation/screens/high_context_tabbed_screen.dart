import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:localaudioplayer/presentation/screens/library_screen.dart';
import 'package:localaudioplayer/presentation/screens/now_playing_screen.dart';
import 'package:localaudioplayer/presentation/screens/podcasts_screen.dart';
import 'package:localaudioplayer/presentation/screens/settings_screen.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/display_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'package:localaudioplayer/presentation/screens/widgets/remote_control_glow.dart';

class HighContextTabbedScreen extends StatefulWidget {
  const HighContextTabbedScreen({super.key});

  @override
  State<HighContextTabbedScreen> createState() =>
      _HighContextTabbedScreenState();
}

class _HighContextTabbedScreenState extends State<HighContextTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _tabNames = [
    'NOW PLAYING',
    'LIBRARY',
    'PODCASTS',
    'SETTINGS',
  ];

  @override
  Widget build(BuildContext context) {
    final playerVM = context.watch<PlayerViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);
    final String style = _getStyleFromName(settingsVM.themeModel.name);
    final bool isDynamic = settingsVM.isDynamicTheme;

    Color primaryColor = theme.colorScheme.primary;
    if (isDynamic && playerVM.extractedColor != null) {
      primaryColor = playerVM.extractedColor!;
    }

    return RemoteControlGlow(
      enabled: playerVM.isRemoteMode || playerVM.isHostMode,
      isHost: playerVM.isHostMode,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: [
            if (style != 'flat' && style != 'ceramic')
              _buildBackground(theme, primaryColor),
            SafeArea(
              child: Column(
                children: [
                  _buildMergedHeader(context, theme, primaryColor),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        const NowPlayingScreen(isTabbed: true),
                        const LibraryScreen(),
                        const PodcastsScreen(),
                        const SettingsScreen(),
                      ],
                    ),
                  ),
                  _buildPersistentFloatingBar(
                    context,
                    theme,
                    style,
                    primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStyleFromName(String name) {
    if (name.contains('Origami')) return 'flat';
    if (name.contains('Hatched')) return 'hatched';
    if (name.contains('Ceramic')) return 'ceramic';
    return 'glass';
  }

  Widget _buildBackground(ThemeData theme, Color primary) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            primary.withValues(alpha: 0.12),
            theme.colorScheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildMergedHeader(
    BuildContext context,
    ThemeData theme,
    Color primary,
  ) {
    final displayVM = context.read<DisplayViewModel>();
    final bool isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final bool isMac = !kIsWeb && Platform.isMacOS;

    return Column(
      children: [
        if (isDesktop) _buildWindowTitleBar(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24.0 : 16.0,
            vertical: isDesktop ? 8.0 : 8.0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 1100;

              // Zoom-style single line integration
              return Row(
                children: [
                  if (isMac && isDesktop) ...[
                    _buildWindowControls(displayVM, theme),
                    const SizedBox(width: 16),
                  ],
                  Text(
                    'AULOS',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: isNarrow
                            ? _buildNarrowNavigation(context, theme, primary)
                            : _buildWideNavigation(context, theme, primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!isMac && isDesktop)
                    _buildWindowControls(displayVM, theme),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWideNavigation(
    BuildContext context,
    ThemeData theme,
    Color primary,
  ) {
    return SizedBox(
      width: 450, // Reduced width for better single-line integration
      child: TabBar(
        controller: _tabController,
        indicatorColor: primary,
        indicatorWeight: 3,
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 9, // Slightly smaller for dense header
        ),
        tabs: _tabNames.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  Widget _buildNarrowNavigation(
    BuildContext context,
    ThemeData theme,
    Color primary,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            size: 20,
          ),
          onPressed: _tabController.index > 0
              ? () => _tabController.animateTo(_tabController.index - 1)
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        _buildCurrentTabDropdown(context, theme),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            size: 20,
          ),
          onPressed: _tabController.index < _tabNames.length - 1
              ? () => _tabController.animateTo(_tabController.index + 1)
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildCurrentTabDropdown(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => _showTabDropdown(context, theme),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _tabNames[_tabController.index],
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showTabDropdown(BuildContext context, ThemeData theme) {
    final RenderBox barBox = context.findRenderObject() as RenderBox;
    final offset = barBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(160, offset.dy + 60, 100, 0),
      color: theme.colorScheme.surface.withValues(alpha: 0.95),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      items: _tabNames.asMap().entries.map((entry) {
        return PopupMenuItem(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              color: _tabController.index == entry.key
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: _tabController.index == entry.key
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        _tabController.animateTo(value);
      }
    });
  }

  Widget _buildWindowTitleBar() {
    return GestureDetector(
      onPanStart: (details) => windowManager.startDragging(),
      child: Container(height: 8, color: Colors.transparent),
    );
  }

  Widget _buildWindowControls(DisplayViewModel displayVM, ThemeData theme) {
    final bool isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final bool isMac = Platform.isMacOS;
    final connectivityVM = context.read<ConnectivityViewModel>();
    final playerVM = context.watch<PlayerViewModel>();
    final controlColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (playerVM.isRemoteMode || playerVM.isHostMode)
          IconButton(
            icon: const Icon(
              Icons.link_off_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
            onPressed: connectivityVM.disconnect,
            tooltip: playerVM.isHostMode
                ? 'Stop Hosting'
                : 'Disconnect from Host',
          ),
        if (isDesktop && !isMac) ...[
          IconButton(
            icon: Icon(Icons.remove, color: controlColor, size: 18),
            onPressed: () => windowManager.minimize(),
            tooltip: 'Minimize',
          ),
          IconButton(
            icon: Icon(
              Icons.crop_square_rounded,
              color: controlColor,
              size: 18,
            ),
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
            tooltip: 'Maximize',
          ),
          IconButton(
            icon: Icon(Icons.close, color: controlColor, size: 18),
            onPressed: () => windowManager.close(),
            tooltip: 'Close',
          ),
        ],
        if (isDesktop && isMac) ...[
          // Simulated Mac-style colored dots if we were doing custom ones, 
          // but usually macOS provides them. We'll just group the status items.
          const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _buildPersistentFloatingBar(
    BuildContext context,
    ThemeData theme,
    String style,
    Color primary,
  ) {
    final playerVM = context.watch<PlayerViewModel>();
    final track = playerVM.currentTrack;
    final bool isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniProgressBar(playerVM, theme, primary),
          const SizedBox(height: 4),
          SizedBox(
            height: 64,
            child: Stack(
              children: [
                // Lower Layer: Track Info (Left aligned)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      borderRadius: BorderRadius.circular(32),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          GestureDetector(
                            onTap: () => _tabController.animateTo(0),
                            child: _buildMiniArt(track?.coverArt, theme),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playerVM.displayTitle,
                                  style: TextStyle(
                                    color: onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${playerVM.currentArtistName} • ${playerVM.currentAlbumName}',
                                  style: TextStyle(
                                    color: onSurface.withValues(alpha: 0.38),
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Higher Layer: Playback Controls (Always Centered)
                Center(
                  child: IgnorePointer(
                    ignoring: false, // Ensure we can still interact
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: onSurface.withValues(alpha: 0.7),
                            size: isDesktop ? 22 : 24,
                          ),
                          onPressed: playerVM.skipPrevious,
                        ),
                        const SizedBox(width: 12),
                        _buildProminentPlayButton(
                          playerVM,
                          theme,
                          isDesktop,
                          primary,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: onSurface.withValues(alpha: 0.7),
                            size: isDesktop ? 22 : 24,
                          ),
                          onPressed: playerVM.skipNext,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(PlayerViewModel vm, ThemeData theme) {
    return InkWell(
      onTap: () {
        final speeds = [0.5, 0.8, 1.0, 1.2, 1.5, 2.0];
        final currentIndex = speeds.indexOf(vm.playbackSpeed);
        final nextIndex = (currentIndex + 1) % speeds.length;
        vm.setSpeed(speeds[nextIndex]);
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${vm.playbackSpeed}x',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniProgressBar(
    PlayerViewModel vm,
    ThemeData theme,
    Color primary,
  ) {
    final pos = vm.position;
    final dur = vm.duration;
    final progress = dur.inMilliseconds > 0
        ? pos.inMilliseconds / dur.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        color: primary,
        minHeight: 2,
      ),
    );
  }

  Widget _buildProminentPlayButton(
    PlayerViewModel vm,
    ThemeData theme,
    bool isDesktop,
    Color primary,
  ) {
    return GestureDetector(
      onTap: vm.isPlaying ? vm.pause : vm.play,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 10 : 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withValues(alpha: 0.1),
          border: Border.all(color: primary.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(
          vm.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: theme.colorScheme.onSurface,
          size: isDesktop ? 28 : 32,
        ),
      ),
    );
  }

  Widget _buildMiniArt(Uint8List? art, ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        image: art != null && art.isNotEmpty
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : null,
      ),
      child: art == null || art.isEmpty
          ? Icon(
              Icons.music_note,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
              size: 22,
            )
          : null,
    );
  }
}
