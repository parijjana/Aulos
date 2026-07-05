import 'package:flutter/material.dart';
import 'mood_dashboard_screen.dart';
import 'now_playing_screen.dart';

class MainPagerScreen extends StatefulWidget {
  final bool isTabbed;

  const MainPagerScreen({super.key, this.isTabbed = false});

  @override
  State<MainPagerScreen> createState() => _MainPagerScreenState();
}

class _MainPagerScreenState extends State<MainPagerScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollToDashboardNotification>(
        onNotification: (notification) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return true;
        },
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(), // Prevent bouncy overscroll issues with inner scroll views
          children: [
            const MoodDashboardScreen(),
            NowPlayingScreen(isTabbed: widget.isTabbed),
          ],
        ),
      ),
    );
  }
}
