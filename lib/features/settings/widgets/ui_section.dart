import 'package:flutter/material.dart';
import 'package:themer_flutter/themer_flutter.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/features/settings/widgets/settings_shared.dart';

class UiSection extends StatelessWidget {
  final SettingsViewModel vm;

  const UiSection({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'UI SETTINGS',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsLabel('THEME PRESET'),
            _buildThemeDropdown(theme),
            const SizedBox(height: 24),
            const SettingsLabel('ARTWORK SHAPE'),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceChip(
                    label: 'SQUARES',
                    isSelected: vm.artworkShape == ArtworkShape.square,
                    onTap: () => vm.setArtworkShape(ArtworkShape.square),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChoiceChip(
                    label: 'CIRCLES',
                    isSelected: vm.artworkShape == ArtworkShape.circle,
                    onTap: () => vm.setArtworkShape(ArtworkShape.circle),
                    theme: theme,
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: Colors.white10),
            const SettingsLabel('VISUAL EFFECTS'),
            _buildSwitchTile(
              label: 'Host Atmosphere Glow',
              value: vm.showHostAnimation,
              onChanged: vm.setShowHostAnimation,
              theme: theme,
            ),
            _buildSwitchTile(
              label: 'Remote Playback Glow',
              value: vm.showRemoteAnimation,
              onChanged: vm.setShowRemoteAnimation,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDropdown(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: DropdownButton<ThemerModel>(
        value: vm.themeModel,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: theme.colorScheme.surface,
        items: vm.availableThemes.map((t) => DropdownMenuItem(
          value: t,
          child: Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        )).toList(),
        onChanged: (val) {
          if (val != null) vm.setTheme(val);
        },
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
