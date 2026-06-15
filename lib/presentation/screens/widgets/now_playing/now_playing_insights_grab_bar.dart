import 'package:flutter/material.dart';

class NowPlayingInsightsGrabBar extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onTap;

  const NowPlayingInsightsGrabBar({
    super.key,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          key: const Key('insights_grab_bar'),
          onTap: onTap,
          child: Container(
            width: 24,
            height: 100,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
            ),
            child: Icon(Icons.insights, size: 16, color: primaryColor.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }
}
