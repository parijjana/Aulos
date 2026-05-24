import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:provider/provider.dart';

class RadioLibraryView extends StatefulWidget {
  final VoidCallback? onExplore;
  const RadioLibraryView({super.key, this.onExplore});

  @override
  State<RadioLibraryView> createState() => _RadioLibraryViewState();
}

class _RadioLibraryViewState extends State<RadioLibraryView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final radioVM = context.watch<RadioViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'FAVORITE STATIONS',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: radioVM.toggleShowingHidden,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                icon: Icon(radioVM.isShowingHidden ? Icons.visibility : Icons.visibility_off, size: 14),
                label: Text(
                  radioVM.isShowingHidden ? 'HIDE HIDDEN' : 'SHOW HIDDEN',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
              if (widget.onExplore != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: widget.onExplore,
                  icon: const Icon(Icons.explore_outlined, size: 16),
                  label: const Text('FIND MORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
        if (radioVM.favorites.isEmpty && !radioVM.isShowingHidden)
          Expanded(child: _buildEmptyState(context, onSurface, radioVM))
        else
          Expanded(
            child: ListView.separated(
              key: const PageStorageKey('radio_library_list'),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              itemCount: radioVM.favorites.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: onSurface.withValues(alpha: 0.05)),
              itemBuilder: (context, index) {
// ... (rest of itemBuilder remains the same)
              final station = radioVM.favorites[index];
              final bool isAvailable = station.isAvailable;

              return Opacity(
                opacity: isAvailable ? 1.0 : 0.4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: _buildFavicon(station, theme),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          station.name, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            color: station.isHidden ? onSurface.withValues(alpha: 0.38) : null,
                            decoration: isAvailable ? null : TextDecoration.lineThrough,
                          )
                        ),
                      ),
                      if (station.isPinned)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.push_pin, size: 12, color: theme.colorScheme.primary),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${station.country ?? "Global"} • ${station.bitrate}kbps ${station.codec ?? ""}',
                    style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.38)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          station.isPinned ? Icons.favorite : Icons.favorite_border,
                          color: station.isPinned ? Colors.pinkAccent : onSurface.withValues(alpha: 0.24),
                          size: 20,
                        ),
                        onPressed: () => radioVM.togglePin(station),
                        tooltip: station.isPinned ? 'Unpin' : 'Pin to Top',
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: onSurface.withValues(alpha: 0.24), size: 20),
                        onSelected: (val) {
                          if (val == 'hide') radioVM.toggleHidden(station);
                          if (val == 'remove') radioVM.toggleFavorite(station);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'hide',
                            child: Row(
                              children: [
                                Icon(station.isHidden ? Icons.visibility : Icons.visibility_off, size: 18),
                                const SizedBox(width: 12),
                                Text(station.isHidden ? 'Show Station' : 'Hide Station'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                const SizedBox(width: 12),
                                Text('Remove from Library', style: TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => radioVM.playStation(station, playerVM),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, Color onSurface, RadioViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radio, size: 64, color: onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'No saved radio stations.',
            style: TextStyle(color: onSurface.withValues(alpha: 0.38)),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: vm.toggleShowingHidden,
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('SHOW HIDDEN STATIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFavicon(RadioStation station, ThemeData theme) {
    final url = station.favicon;
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: url != null && url.isNotEmpty
                ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.radio, size: 20))
                : const Icon(Icons.radio, size: 20),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: station.isAvailable ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
