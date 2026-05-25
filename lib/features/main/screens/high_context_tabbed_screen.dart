import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/features/library/widgets/music_library_view.dart';
import 'package:aulos/presentation/screens/now_playing_screen.dart';
import 'package:aulos/features/podcasts/screens/podcast_root_screen.dart';
import 'package:aulos/features/radio/screens/radio_root_screen.dart';
import 'package:aulos/features/noise/screens/noise_root_screen.dart';
import 'package:aulos/features/settings/screens/settings_screen.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:provider/provider.dart';

import 'package:aulos/presentation/screens/widgets/remote_control_glow.dart';
import '../widgets/main_tab_header.dart';
import '../widgets/persistent_player_bar.dart';

class HighContextTabbedScreen extends StatefulWidget {
  const HighContextTabbedScreen({super.key});

  @override
  State<HighContextTabbedScreen> createState() => _HighContextTabbedScreenState();
}

class _HighContextTabbedScreenState extends State<HighContextTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lastKnownVmIndex = 0;

  @override
  void initState() {
    super.initState();
    final displayVM = context.read<DisplayViewModel>();
    _lastKnownVmIndex = displayVM.selectedTabIndex;
    
    _tabController = TabController(
      length: 6, 
      vsync: this,
      initialIndex: _lastKnownVmIndex.clamp(0, 5),
    );

    _tabController.addListener(_handleTabControllerChange);
  }

  void _handleTabControllerChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
      return;
    }
    
    final displayVM = context.read<DisplayViewModel>();
    if (displayVM.selectedTabIndex != _tabController.index) {
      _lastKnownVmIndex = _tabController.index;
      displayVM.setTabIndex(_tabController.index);
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final displayVM = context.watch<DisplayViewModel>();
    
    if (_lastKnownVmIndex != displayVM.selectedTabIndex) {
      _lastKnownVmIndex = displayVM.selectedTabIndex;
      _tabController.animateTo(displayVM.selectedTabIndex.clamp(0, 5));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabControllerChange);
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _tabNames = [
    'NOW PLAYING',
    'MUSIC',
    'PODCASTS',
    'RADIO',
    'NOISE',
    'SETTINGS'
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
            if (style != 'flat' && style != 'ceramic') _buildBackground(theme, primaryColor),
            SafeArea(
              child: Column(
                children: [
                  MainTabHeader(
                    tabController: _tabController,
                    tabNames: _tabNames,
                    primaryColor: primaryColor,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const NowPlayingScreen(isTabbed: true),
                        const MusicLibraryView(),
                        const PodcastRootScreen(),
                        const RadioRootScreen(),
                        const NoiseRootScreen(),
                        const SettingsScreen(),
                      ],
                    ),
                  ),
                  if (_tabController.index != 0)
                    PersistentPlayerBar(
                      tabController: _tabController,
                      primaryColor: primaryColor,
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
          colors: [primary.withValues(alpha: 0.12), theme.colorScheme.surface],
        ),
      ),
    );
  }
}
