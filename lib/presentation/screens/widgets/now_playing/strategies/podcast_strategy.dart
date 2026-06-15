import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/html_text.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'now_playing_strategy.dart';
import '../now_playing_controls.dart';

class PodcastStrategy extends NowPlayingStrategy {
  @override
  String get sectionLabel => 'SHOW NOTES';

  @override
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize, {bool isOverlay = false}) {
    final width = MediaQuery.of(context).size.width;
    final showSecondary = width > 400 && !isOverlay;
    final showSkips = width > 250;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSecondary) ...[
            buildSpeedSelector(vm, theme, isOverlay: isOverlay),
            const SizedBox(width: 16),
          ],
          if (showSkips) ...[
            buildCircularButton(Icons.replay_10_rounded, vm.skipBackward, buttonSize, theme, isOverlay: isOverlay),
            const SizedBox(width: 16),
          ],
          buildAulosPlayButton(vm, theme, primarySize),
          if (showSkips) ...[
            const SizedBox(width: 16),
            buildCircularButton(Icons.forward_10_rounded, vm.skipForward, buttonSize, theme, isOverlay: isOverlay),
          ],
          if (showSecondary) ...[
            const SizedBox(width: 16),
            buildCircularButton(
              vm.isBookmarkMode ? Icons.check_circle : Icons.bookmark_add_outlined, 
              () {
                if (vm.isBookmarkMode) {
                  showRichBookmarkDialog(context, vm, theme);
                } else {
                  vm.toggleBookmark();
                }
              }, 
              buttonSize, 
              theme,
              color: vm.isBookmarkMode ? theme.colorScheme.primary : null,
              isOverlay: isOverlay,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, PlayerViewModel vm, ThemeData theme) {
    return HtmlText(
      vm.currentShowNotes ?? 'No notes available.',
      onTimestampTap: (d) => vm.seek(d),
    );
  }
}
