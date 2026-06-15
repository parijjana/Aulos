import 'package:flutter/material.dart';
import 'package:aulos/features/library/widgets/music_library_view.dart';
import 'package:aulos/features/library/widgets/jamendo_discover_view.dart';
import 'package:provider/provider.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';

class MusicRootScreen extends StatefulWidget {
  const MusicRootScreen({super.key});

  @override
  State<MusicRootScreen> createState() => _MusicRootScreenState();
}

class _MusicRootScreenState extends State<MusicRootScreen> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  int _activeTab = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut
    );
    setState(() => _activeTab = index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final libraryVM = context.watch<LibraryViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildUnifiedHeader(libraryVM),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeTab = index),
              children: const [
                MusicLibraryView(),
                JamendoDiscoverView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedHeader(LibraryViewModel vm) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildNavButton('LIBRARY', 0, _activeTab == 0, theme),
          const SizedBox(width: 8),
          _buildNavButton('DISCOVER', 1, _activeTab == 1, theme),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, int index, bool isActive, ThemeData theme) {
    return InkWell(
      onTap: () => _navigateToPage(index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isActive ? null : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
