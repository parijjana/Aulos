import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:provider/provider.dart';

class NowPlayingVolume extends StatelessWidget {
  const NowPlayingVolume({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerViewModel>();
    final noiseVM = context.watch<NoiseViewModel>();
    final theme = Theme.of(context);
    final isNoise = vm.currentMediaType == MediaType.noise;

    return Center(
      child: SizedBox(
        width: 300, // Reverted to fixed width standard
        child: Row(
          children: [
            Icon(Icons.volume_mute, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 18),
            Expanded(
              child: Slider(
                value: isNoise ? noiseVM.masterVolume : vm.volume,
                onChanged: (val) {
                  if (isNoise) {
                    noiseVM.setMasterVolume(val);
                  } else {
                    vm.setVolume(val);
                  }
                },
                activeColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            Icon(Icons.volume_up, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 18),
          ],
        ),
      ),
    );
  }
}
