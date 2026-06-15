import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';

class NowPlayingTrackInfo extends StatelessWidget {
  final PlayerViewModel vm;
  final bool isCompact;

  const NowPlayingTrackInfo({
    super.key,
    required this.vm,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Text(
            vm.displayTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 22 : 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            vm.currentArtistName,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: isCompact ? 14 : 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
