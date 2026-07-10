import 'package:flutter/material.dart';
import 'package:aulos/features/library/widgets/podcast_library_view.dart';
import 'package:aulos/features/podcasts/screens/podcast_browser_screen.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/features/podcasts/widgets/podcast_bookmarks_sidebar.dart';
import 'package:provider/provider.dart';

class PodcastRootScreen extends StatefulWidget {
  const PodcastRootScreen({super.key});

  @override
  State<PodcastRootScreen> createState() => _PodcastRootScreenState();
}

class _PodcastRootScreenState extends State<PodcastRootScreen> {
  final PageController _pageController = PageController();
  bool _showBookmarks = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final podcastVM = context.watch<PodcastViewModel>();
    final isDesktop = MediaQuery.of(context).size.width > 1100;
    final bool podcastStackNotEmpty = podcastVM.activePodcast != null;
    final bool podcastTempShowHome = podcastVM.tempShowHome;

    return PopScope(
      canPop: !podcastStackNotEmpty && !podcastTempShowHome,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (podcastTempShowHome) {
          podcastVM.setTempShowHome(false);
          return;
        }
        podcastVM.setActivePodcast(null);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                _buildTopBar(isDesktop, settingsVM),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      PodcastLibraryView(),
                      PodcastBrowserScreen(),
                    ],
                  ),
                ),
              ],
            ),
          
          // BOOKMARKS SIDEBAR (Pull-tab style)
          if (isDesktop)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              right: _showBookmarks ? 0 : -350,
              top: 0,
              bottom: 0,
              child: Row(
                children: [
                  _buildPullTab(),
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 40)],
                    ),
                    child: const PodcastBookmarksSidebar(),
                  ),
                ],
              ),
            ),
        ],
      ),
     ),
    );
  }
  Widget _buildTopBar(bool isDesktop, settings.SettingsViewModel settingsVM) {
    final theme = Theme.of(context);
    final podcastVM = context.watch<PodcastViewModel>();
    int currentPage = 0;
    if (_pageController.hasClients) {
      currentPage = _pageController.page?.round() ?? 0;
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth <= 380 ? 12 : 24;
    final double buttonSpacing = screenWidth <= 380 ? 4 : 8;
    final bool podcastStackNotEmpty = podcastVM.activePodcast != null;
    final bool podcastTempShowHome = podcastVM.tempShowHome;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          if (podcastStackNotEmpty) ...[
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary, size: 16),
              onPressed: () {
                if (podcastTempShowHome) {
                  podcastVM.setTempShowHome(false);
                } else {
                  podcastVM.setActivePodcast(null);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: Icon(
              podcastTempShowHome ? Icons.home : Icons.home_outlined,
              color: podcastTempShowHome
                  ? theme.colorScheme.primary
                  : (!podcastStackNotEmpty
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                      : theme.colorScheme.primary),
              size: 20,
            ),
            onPressed: !podcastStackNotEmpty
                ? null
                : () => podcastVM.setTempShowHome(!podcastTempShowHome),
            tooltip: 'Home View',
          ),
          const SizedBox(width: 12),
          _buildNavButton(screenWidth <= 380 ? 'LIBRARY' : 'YOUR LIBRARY', 0, currentPage == 0, theme),
          SizedBox(width: buttonSpacing),
          _buildNavButton(screenWidth <= 380 ? 'DISCOVER' : 'FIND MORE', 1, currentPage == 1, theme),
          
          const Spacer(),
          
          if (currentPage == 0) ...[
            IconButton(
              onPressed: () => podcastVM.loadPodcasts(),
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh Library',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (screenWidth <= 380) const SizedBox(width: 8) else const SizedBox(width: 12),
          ],
          
          _ViewModeSelector(settingsVM: settingsVM),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, int index, bool isActive, ThemeData theme) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizPadding = screenWidth <= 380 ? 8 : 16;
    final double vertPadding = screenWidth <= 380 ? 4 : 10;
    final double fontSize = screenWidth <= 380 ? 8 : 10;

    return InkWell(
      onTap: () {
        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
        setState(() {});
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizPadding, vertical: vertPadding),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }

  Widget _buildPullTab() {
    return GestureDetector(
      onTap: () => setState(() => _showBookmarks = !_showBookmarks),
      child: Container(
        width: 32,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
        ),
        child: Icon(
          _showBookmarks ? Icons.chevron_right : Icons.bookmark_outline,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ViewModeSelector extends StatelessWidget {
  final settings.SettingsViewModel settingsVM;
  const _ViewModeSelector({required this.settingsVM});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return PopupMenuButton<settings.LibraryViewType>(
      initialValue: settingsVM.libraryViewType,
      onSelected: settingsVM.setLibraryViewType,
      icon: Icon(Icons.grid_view_rounded, color: primary.withValues(alpha: 0.7), size: 20),
      tooltip: 'View Mode',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: settings.LibraryViewType.list,
          child: Row(
            children: [
              Icon(Icons.list, size: 18, color: settingsVM.libraryViewType == settings.LibraryViewType.list ? primary : onSurface),
              const SizedBox(width: 12),
              const Text('List View', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: settings.LibraryViewType.grid,
          child: Row(
            children: [
              Icon(Icons.grid_view, size: 18, color: settingsVM.libraryViewType == settings.LibraryViewType.grid ? primary : onSurface),
              const SizedBox(width: 12),
              const Text('Grid View', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
