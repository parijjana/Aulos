import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';

class NowPlayingBackground extends StatelessWidget {
  final PlayerViewModel vm;

  const NowPlayingBackground({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final art = vm.currentTrack?.coverArt;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: theme.colorScheme.surface),
        ),
        if (art != null && art.isNotEmpty)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Opacity(
                opacity: 0.22,
                child: Image.memory(art, fit: BoxFit.cover),
              ),
            ),
          ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
