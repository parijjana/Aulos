import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'now_playing_strategy.dart';
import '../now_playing_controls.dart';

class RadioStrategy extends NowPlayingStrategy {
  @override
  String get sectionLabel => 'STATION INFO';

  @override
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize, {bool isOverlay = false}) {
    final width = MediaQuery.of(context).size.width;
    final showSecondary = width > 280 && !isOverlay;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showSecondary) ...[
          IconButton(
            icon: Icon(
              vm.isCurrentStationFavorite ? Icons.library_add_check : Icons.library_add,
              color: vm.isCurrentStationFavorite ? theme.colorScheme.primary : (isOverlay ? Colors.white30 : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              size: 24,
            ),
            onPressed: vm.toggleCurrentStationFavorite,
            tooltip: vm.isCurrentStationFavorite ? 'In Library' : 'Add to Library',
          ),
          const SizedBox(width: 24),
        ],
        buildAulosPlayButton(vm, theme, primarySize),
        if (showSecondary) ...[
          const SizedBox(width: 24),
          const SizedBox(width: 48), 
        ],
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
            if (vm.currentRadioStation != null) ...[
              const SizedBox(height: 24),
              _buildMetadataGrid(vm.currentRadioStation!, theme),
            ],
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

  Widget _buildMetadataGrid(dynamic station, ThemeData theme) {
    final country = station.country as String?;
    final language = station.language as String?;
    final tags = station.tags as String?;
    final bitrate = station.bitrate as int?;
    final codec = station.codec as String?;
    final votes = station.votes as int?;

    final List<Map<String, String>> items = [
      if (country != null && country.isNotEmpty) {'label': 'COUNTRY', 'value': country},
      if (language != null && language.isNotEmpty) {'label': 'LANGUAGE', 'value': language},
      if (bitrate != null && bitrate > 0) {'label': 'BITRATE', 'value': '$bitrate kbps'},
      if (codec != null && codec.isNotEmpty) {'label': 'CODEC', 'value': codec.toUpperCase()},
      if (votes != null && votes > 0) {'label': 'VOTES', 'value': votes.toString()},
    ];

    return Column(
      children: [
        if (items.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['label']!,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['value']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        if (tags != null && tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'TAGS',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).take(8).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
