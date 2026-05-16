import 'package:flutter/material.dart' hide RepeatMode;
import 'package:localaudioplayer/features/library/screens/library_screen.dart';
import 'package:localaudioplayer/presentation/screens/now_playing_screen.dart';
import 'package:localaudioplayer/presentation/screens/podcasts_screen.dart';
import 'package:localaudioplayer/features/settings/screens/settings_screen.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

import 'package:localaudioplayer/presentation/screens/widgets/remote_control_glow.dart';
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

  final List<String> _tabNames = ['NOW PLAYING', 'LIBRARY', 'PODCASTS', 'SETTINGS'];

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
                      children: [
                        const NowPlayingScreen(isTabbed: true),
                        const LibraryScreen(),
                        const PodcastsScreen(),
                        const SettingsScreen(),
                      ],
                    ),
                  ),
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
