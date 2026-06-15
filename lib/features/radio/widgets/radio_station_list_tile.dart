import 'package:flutter/material.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class RadioStationListTile extends StatelessWidget {
  final RadioStation station;
  final RadioViewModel vm;

  const RadioStationListTile({
    super.key,
    required this.station,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);
    final bool isAvailable = station.isAvailable;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.4,
      child: ListTile(
        dense: true,
        leading: _buildFavicon(station, theme),
        title: Text(
          station.name, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 13,
            decoration: isAvailable ? null : TextDecoration.lineThrough,
          )
        ),
        subtitle: Row(
          children: [
            Text('${station.country ?? "Global"} • ${station.bitrate}kbps', style: const TextStyle(fontSize: 10)),
            const Spacer(),
            const Icon(Icons.thumb_up_alt_outlined, size: 10, color: Colors.white38),
            const SizedBox(width: 4),
            Text(station.votes.toString(), style: const TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(station.isFavorite ? Icons.library_add_check : Icons.library_add, 
               color: station.isFavorite ? theme.colorScheme.primary : null, size: 18),
          onPressed: () => vm.toggleFavorite(station),
        ),
        onTap: () => vm.playStation(station, playerVM, isAvailable: isAvailable),
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
