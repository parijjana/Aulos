import 'package:flutter/material.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class RadioStationGridTile extends StatelessWidget {
  final RadioStation station;
  final RadioViewModel vm;
  final VoidCallback onInfoPressed;

  const RadioStationGridTile({
    super.key,
    required this.station,
    required this.vm,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);
    final bool isAvailable = station.isAvailable;
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () => vm.playStation(station, playerVM, isAvailable: isAvailable),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildFavicon(station, theme, large: true),
                  
                  // Top-Right Info Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onInfoPressed,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-Third Translucent "Add to Library" Button
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.33,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              vm.toggleFavorite(station);
                            },
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.55),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      station.isFavorite ? Icons.library_add_check : Icons.library_add,
                                      color: station.isFavorite ? theme.colorScheme.primary : Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      station.isFavorite ? 'IN LIBRARY' : 'ADD TO LIBRARY',
                                      style: TextStyle(
                                        color: station.isFavorite ? theme.colorScheme.primary : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              station.name, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                decoration: isAvailable ? null : TextDecoration.lineThrough,
              )
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${station.country ?? "Global"} • ${station.bitrate}k', 
                    style: TextStyle(fontSize: 9, color: onSurface.withValues(alpha: 0.38)),
                    maxLines: 1,
                  ),
                ),
                const Icon(Icons.thumb_up_alt_outlined, size: 8, color: Colors.white24),
                const SizedBox(width: 2),
                Text(station.votes.toString(), style: const TextStyle(fontSize: 8, color: Colors.white24)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavicon(RadioStation station, ThemeData theme, {bool large = false}) {
    final url = station.favicon;
    return Stack(
      children: [
        Container(
          width: large ? double.infinity : 32,
          height: large ? double.infinity : 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(large ? 12 : 4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(large ? 12 : 4),
            child: url != null && url.isNotEmpty
                ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.radio, size: large ? 48 : 16))
                : Icon(Icons.radio, size: large ? 48 : 16),
          ),
        ),
        if (station.lastCheck != null)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: large ? 12 : 8,
              height: large ? 12 : 8,
              decoration: BoxDecoration(
                color: station.isAvailable ? Colors.greenAccent : Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 1),
              ),
            ),
          ),
      ],
    );
  }
}
