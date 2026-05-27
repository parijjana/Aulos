import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'now_playing_strategy.dart';
import '../now_playing_controls.dart';

class RadioStrategy extends NowPlayingStrategy {
  @override
  String get sectionLabel => 'STATION INFO';

  @override
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            vm.isCurrentStationFavorite ? Icons.library_add_check : Icons.library_add,
            color: vm.isCurrentStationFavorite ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 24,
          ),
          onPressed: vm.toggleCurrentStationFavorite,
          tooltip: vm.isCurrentStationFavorite ? 'In Library' : 'Add to Library',
        ),
        const SizedBox(width: 24),
        buildAulosPlayButton(vm, theme, primarySize),
        const SizedBox(width: 24),
        const SizedBox(width: 48), 
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context, PlayerViewModel vm, ThemeData theme) {
    final metadata = vm.currentShowNotes?.split('|');
    final homepage = (metadata != null && metadata.length > 1) ? metadata[1] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.radio, size: 64, color: Colors.white10),
            const SizedBox(height: 32),
            if (vm.currentStreamMetadata != null)
              Text(
                vm.currentStreamMetadata!,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: theme.colorScheme.primary, letterSpacing: -0.5),
              )
            else
              Text('Live Stream: ${vm.displayTitle}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('INTERNET RADIO', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
            if (homepage != null && homepage.isNotEmpty) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(homepage)),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('VISIT STATION HOMEPAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05), foregroundColor: theme.colorScheme.onSurface, elevation: 0),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
