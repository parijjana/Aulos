import 'package:flutter/material.dart';
import 'package:aulos/features/library/widgets/radio_library_view.dart';
import 'package:aulos/features/radio/screens/radio_browser_screen.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:provider/provider.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
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
    final radioVM = context.watch<RadioViewModel>();

    return PopScope(
      canPop: !radioVM.tempShowHome,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (radioVM.tempShowHome) {
          radioVM.setTempShowHome(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                _buildTopBar(settingsVM, radioVM),
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
            if (radioVM.tempShowHome)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTopBar(settingsVM, radioVM),
                      const SizedBox(height: 8),
                      const Expanded(child: RadioLibraryView()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildTopBar(settings.SettingsViewModel settingsVM, RadioViewModel radioVM) {
    final theme = Theme.of(context);
    int currentPage = 0;
    if (_pageController.hasClients) {
      currentPage = _pageController.page?.round() ?? 0;
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth <= 380 ? 12 : 24;
    final double buttonSpacing = screenWidth <= 380 ? 4 : 8;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              radioVM.tempShowHome ? Icons.home : Icons.home_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () => radioVM.setTempShowHome(!radioVM.tempShowHome),
            tooltip: 'Home View',
          ),
          const SizedBox(width: 12),
          _buildNavButton('YOUR LIBRARY', 0, currentPage == 0, theme),
          SizedBox(width: buttonSpacing),
          _buildNavButton('FIND MORE', 1, currentPage == 1, theme),
          
          const Spacer(),
          
          // View Mode Selector (Unified UX)
          _ViewModeSelector(settingsVM: settingsVM),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, int index, bool isActive, ThemeData theme) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizPadding = screenWidth <= 380 ? 8 : 12;
    final double vertPadding = screenWidth <= 380 ? 4 : 6;
    final double fontSize = screenWidth <= 380 ? 8 : 9;

    return InkWell(
      onTap: () => _navigateToPage(index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizPadding, vertical: vertPadding),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isActive ? null : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
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
