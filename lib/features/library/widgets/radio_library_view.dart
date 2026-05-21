import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/radio_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/data/database/radio_database.dart';
import 'package:provider/provider.dart';

class RadioLibraryView extends StatefulWidget {
  const RadioLibraryView({super.key});

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

    if (radioVM.favorites.isEmpty) {
      return _buildEmptyState(context, onSurface);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: radioVM.favorites.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: onSurface.withValues(alpha: 0.05)),
      itemBuilder: (context, index) {
        final station = radioVM.favorites[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildFavicon(station.favicon, theme),
          title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(
            '${station.country ?? "Global"} • ${station.bitrate}kbps ${station.codec ?? ""}',
            style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.38)),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 20),
            onPressed: () => radioVM.toggleFavorite(station),
          ),
          onTap: () => radioVM.playStation(station, playerVM),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, Color onSurface) {
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
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Discover Radio Tab (Index 3)
              // context.read<DisplayViewModel>().setTabIndex(3);
            },
            icon: const Icon(Icons.language),
            label: const Text('DISCOVER GLOBAL RADIO'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavicon(String? url, ThemeData theme) {
    return Container(
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
    );
  }
}
