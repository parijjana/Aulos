import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';

class EffectsSection extends StatelessWidget {
  final SettingsViewModel vm;

  const EffectsSection({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'VISUAL EFFECTS',
      child: Column(
        children: [
          SwitchListTile(
            dense: true,
            title: Text('Host Glow', style: TextStyle(color: onSurface, fontSize: 12)),
            value: vm.showHostAnimation,
            onChanged: (val) => vm.setShowHostAnimation(val),
          ),
          SwitchListTile(
            dense: true,
            title: Text('Remote Glow', style: TextStyle(color: onSurface, fontSize: 12)),
            value: vm.showRemoteAnimation,
            onChanged: (val) => vm.setShowRemoteAnimation(val),
          ),
        ],
      ),
    );
  }
}
