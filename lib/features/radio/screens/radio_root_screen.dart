import 'package:flutter/material.dart';
import 'package:aulos/features/library/widgets/radio_library_view.dart';
import 'package:aulos/features/radio/screens/radio_browser_screen.dart';

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

  void _navigateToExplore() {
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _navigateToLibrary() {
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: RadioLibraryView(onExplore: _navigateToExplore),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: RadioBrowserScreen(onBack: _navigateToLibrary),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, {VoidCallback? onExplore, VoidCallback? onBack}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (onBack != null) 
                IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: onBack),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          if (onExplore != null)
            TextButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.explore_outlined, size: 16),
              label: const Text('FIND MORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
