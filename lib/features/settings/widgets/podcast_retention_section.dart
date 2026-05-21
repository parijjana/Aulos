import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';

class PodcastRetentionSection extends StatelessWidget {
  final SettingsViewModel vm;

  const PodcastRetentionSection({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'PODCAST STORAGE',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KEEP EPISODES',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.38),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSliderRow(
              label: 'Max per Podcast',
              value: vm.podcastKeepCount.toDouble(),
              min: 1,
              max: 50,
              onChanged: (val) => vm.setPodcastKeepCount(val.toInt()),
              displayValue: '${vm.podcastKeepCount} latest',
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildSliderRow(
              label: 'Delete after',
              value: vm.podcastKeepDays.toDouble(),
              min: 1,
              max: 90,
              onChanged: (val) => vm.setPodcastKeepDays(val.toInt()),
              displayValue: '${vm.podcastKeepDays} days',
              theme: theme,
            ),
            const SizedBox(height: 8),
            Text(
              'Pinned episodes are never auto-deleted.',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.24),
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String displayValue,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(displayValue, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
