import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class MainTabHeader extends StatelessWidget {
  final TabController tabController;
  final List<String> tabNames;
  final Color primaryColor;

  const MainTabHeader({
    super.key,
    required this.tabController,
    required this.tabNames,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayVM = context.read<DisplayViewModel>();
    final bool isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final bool isMac = !kIsWeb && Platform.isMacOS;

    return Column(
      children: [
        if (isDesktop) _buildWindowTitleBar(),
        SizedBox(
          height: 60,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24.0 : 16.0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 1100;

                return Row(
                  children: [
                    if (isMac && isDesktop) ...[
                      _buildWindowControls(context, theme),
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
                              ? _buildNarrowNavigation(context, theme)
                              : _buildWideNavigation(theme),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!isMac && isDesktop)
                      _buildWindowControls(context, theme),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWindowTitleBar() {
    return GestureDetector(
      onPanStart: (details) => windowManager.startDragging(),
      child: Container(height: 8, color: Colors.transparent),
    );
  }

  Widget _buildWindowControls(BuildContext context, ThemeData theme) {
    final bool isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final bool isMac = !kIsWeb && Platform.isMacOS;
    final connectivityVM = context.read<ConnectivityViewModel>();
    final playerVM = context.watch<PlayerViewModel>();
    final controlColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (playerVM.isRemoteMode || playerVM.isHostMode)
          IconButton(
            icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 18),
            onPressed: connectivityVM.disconnect,
            tooltip: playerVM.isHostMode ? 'Stop Hosting' : 'Disconnect from Host',
          ),
        if (isDesktop && !isMac) ...[
          IconButton(
            icon: Icon(Icons.fullscreen_rounded, color: controlColor, size: 18),
            onPressed: () async {
              final bool isFullScreen = await windowManager.isFullScreen();
              await windowManager.setFullScreen(!isFullScreen);
            },
            tooltip: 'Toggle Full Screen',
          ),
          IconButton(
            icon: Icon(Icons.remove, color: controlColor, size: 18),
            onPressed: () => windowManager.minimize(),
          ),
          IconButton(
            icon: Icon(Icons.crop_square_rounded, color: controlColor, size: 18),
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.close, color: controlColor, size: 18),
            onPressed: () => windowManager.close(),
          ),
        ],
      ],
    );
  }

  Widget _buildWideNavigation(ThemeData theme) {
    return SizedBox(
      width: 600,
      child: TabBar(
        controller: tabController,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        labelColor: theme.colorScheme.onSurface,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 9),
        tabs: tabNames.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  Widget _buildNarrowNavigation(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.38), size: 20),
          onPressed: tabController.index > 0 ? () => tabController.animateTo(tabController.index - 1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        _buildCurrentTabDropdown(context, theme),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.38), size: 20),
          onPressed: tabController.index < tabNames.length - 1 ? () => tabController.animateTo(tabController.index + 1) : null,
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
              tabNames[tabController.index],
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface.withValues(alpha: 0.24), size: 14),
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
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      items: tabNames.asMap().entries.map((entry) {
        return PopupMenuItem(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              color: tabController.index == entry.key ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: tabController.index == entry.key ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        tabController.animateTo(value);
      }
    });
  }
}
