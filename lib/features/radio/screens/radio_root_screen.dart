import 'package:flutter/material.dart';
import 'package:aulos/features/library/widgets/radio_library_view.dart';
import 'package:aulos/features/radio/screens/radio_browser_screen.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:provider/provider.dart';

class RadioRootScreen extends StatefulWidget {
  const RadioRootScreen({super.key});

  @override
  State<RadioRootScreen> createState() => _RadioRootScreenState();
}

class _RadioRootScreenState extends State<RadioRootScreen> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settingsVM = context.watch<settings.SettingsViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTopBar(settingsVM),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const RadioLibraryView(),
                RadioBrowserScreen(onBack: () => _navigateToPage(0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(settings.SettingsViewModel settingsVM) {
    final theme = Theme.of(context);
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
          
          // View Mode Selector (Unified UX)
          _ViewModeSelector(settingsVM: settingsVM),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, int index, bool isActive, ThemeData theme) {
    return InkWell(
      onTap: () => _navigateToPage(index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isActive ? null : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
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
      icon: Icon(
        Icons.grid_view_rounded,
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
        size: 20,
      ),
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
        PopupMenuItem(
          value: settings.LibraryViewType.orbit,
          child: Row(
            children: [
              Icon(Icons.blur_circular, size: 18, color: settingsVM.libraryViewType == settings.LibraryViewType.orbit ? primary : onSurface),
              const SizedBox(width: 12),
              const Text('Orbit View', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
