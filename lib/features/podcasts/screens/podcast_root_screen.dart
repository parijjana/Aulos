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
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
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
    );
  }

  Widget _buildTopBar(bool isDesktop, settings.SettingsViewModel settingsVM) {
    final theme = Theme.of(context);
    final podcastVM = context.read<PodcastViewModel>();
    int currentPage = 0;
    if (_pageController.hasClients) {
      currentPage = _pageController.page?.round() ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildNavButton('YOUR LIBRARY', 0, currentPage == 0, theme),
          const SizedBox(width: 8),
          _buildNavButton('FIND MORE', 1, currentPage == 1, theme),
          
          const Spacer(),
          
          if (currentPage == 0)
            IconButton(
              onPressed: () => podcastVM.loadPodcasts(),
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh Library',
              visualDensity: VisualDensity.compact,
            ),
          
          _ViewModeSelector(settingsVM: settingsVM),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, int index, bool isActive, ThemeData theme) {
    return InkWell(
      onTap: () {
        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
        setState(() {});
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
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
    final onSurface = theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.view_module, size: 20, color: settingsVM.libraryViewType == settings.LibraryViewType.grid ? primary : onSurface),
          onPressed: () => settingsVM.setLibraryViewType(settings.LibraryViewType.grid),
          tooltip: 'Grid View',
        ),
        IconButton(
          icon: Icon(Icons.view_list, size: 20, color: settingsVM.libraryViewType == settings.LibraryViewType.list ? primary : onSurface),
          onPressed: () => settingsVM.setLibraryViewType(settings.LibraryViewType.list),
          tooltip: 'List View',
        ),
      ],
    );
  }
}
