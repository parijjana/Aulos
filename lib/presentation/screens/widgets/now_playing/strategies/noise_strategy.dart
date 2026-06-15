import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:provider/provider.dart';
import 'now_playing_strategy.dart';
import '../now_playing_controls.dart';

class NoiseStrategy extends NowPlayingStrategy {
  @override
  String get sectionLabel => 'LOOP ATTRIBUTION';

  @override
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize, {bool isOverlay = false}) {
    final displayVM = context.read<DisplayViewModel>();
    final width = MediaQuery.of(context).size.width;
    final showSecondary = width > 280 && !isOverlay;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showSecondary) ...[
          IconButton(
            onPressed: () {
              displayVM.setTabIndex(5); // NOISE tab
              if (displayVM.mode != UIContextMode.highContext) {
                displayVM.setMode(UIContextMode.highContext);
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 20),
            ),
            tooltip: 'Modify Soundscape',
          ),
          const SizedBox(width: 32),
        ],
        buildAulosPlayButton(vm, theme, primarySize),
        if (showSecondary) ...[
          const SizedBox(width: 32),
          const SizedBox(width: 48), 
        ],
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context, PlayerViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.currentShowNotes ?? 'No attribution available.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.6, letterSpacing: 0.2),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.all_inclusive, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('INFINITE LOOP ACTIVE', style: TextStyle(color: theme.colorScheme.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get showProgress => false;
}
