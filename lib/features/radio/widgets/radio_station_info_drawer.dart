import 'package:flutter/material.dart';
import 'package:aulos/data/database/radio_database.dart';

class RadioStationInfoDrawer extends StatelessWidget {
  final RadioStation station;

  const RadioStationInfoDrawer({
    super.key,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Station Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              // Favicon and Name
              Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: _buildFavicon(station, theme, large: true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      station.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Details List
              Expanded(
                child: ListView(
                  children: [
                    _buildInfoRow(context, 'Stream URL', station.url, isUrl: true),
                    if (station.homepage != null && station.homepage!.isNotEmpty)
                      _buildInfoRow(context, 'Homepage', station.homepage!, isUrl: true),
                    _buildInfoRow(context, 'Codec', station.codec ?? 'Unknown'),
                    _buildInfoRow(context, 'Bitrate', '${station.bitrate} kbps'),
                    _buildInfoRow(context, 'Country', station.country ?? 'Global'),
                    _buildInfoRow(context, 'Language', station.language ?? 'Unknown'),
                    _buildInfoRow(context, 'Votes', station.votes.toString()),
                    if (station.tags != null && station.tags!.isNotEmpty)
                      _buildInfoRow(context, 'Tags', station.tags!.split(',').join(', ')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isUrl = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isUrl ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              decoration: isUrl ? TextDecoration.underline : null,
            ),
          ),
        ],
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
