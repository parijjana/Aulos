import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class NowPlayingVolume extends StatelessWidget {
  const NowPlayingVolume({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.volume_down, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        SizedBox(
          width: 200,
          child: Slider(
            value: vm.volume,
            onChanged: vm.setVolume,
            activeColor: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        Icon(Icons.volume_up, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      ],
    );
  }
}
