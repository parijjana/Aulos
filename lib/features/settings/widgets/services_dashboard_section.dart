import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/features/settings/widgets/settings_shared.dart';
import 'package:aulos/data/library/discovery_sync_manager.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:provider/provider.dart';

class ServicesDashboardSection extends StatefulWidget {
  const ServicesDashboardSection({super.key});

  @override
  State<ServicesDashboardSection> createState() => _ServicesDashboardSectionState();
}

class _ServicesDashboardSectionState extends State<ServicesDashboardSection> {
  bool _podcastServiceEnabled = true;
  bool _artworkServiceEnabled = true;
  bool _radioServiceEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final podcastSync = context.watch<DiscoverySyncManager>();
    final libraryIndexer = context.watch<LibraryIndexerService>();
    final persistentLibrary = context.read<PersistentLibraryService>();

    return GlassCard(
      title: 'SERVICES DASHBOARD',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsLabel('ACTIVE BACKGROUND SERVICES'),
            
            _buildServiceTile(
              label: 'Podcast Discovery Sync',
              icon: Icons.podcasts,
              isEnabled: _podcastServiceEnabled,
              isProcessing: podcastSync.isSyncing,
              onToggle: (val) => setState(() => _podcastServiceEnabled = val),
              status: podcastSync.isSyncing ? 'Syncing Catalog...' : 'Idle',
              theme: theme,
            ),

            const SizedBox(height: 12),

            _buildServiceTile(
              label: 'Cover Art Fetcher',
              icon: Icons.image_search,
              isEnabled: _artworkServiceEnabled,
              isProcessing: libraryIndexer.state == IndexerState.hardening,
              onToggle: (val) => setState(() => _artworkServiceEnabled = val),
              onPauseResume: () {
                if (libraryIndexer.state == IndexerState.hardening) {
                   libraryIndexer.stopIndexer();
                }
              },
              status: _getIndexerStatus(libraryIndexer),
              theme: theme,
            ),

            const SizedBox(height: 12),

            _buildServiceTile(
              label: 'Radio Station Directory',
              icon: Icons.radio,
              isEnabled: _radioServiceEnabled,
              isProcessing: false,
              onToggle: (val) => setState(() => _radioServiceEnabled = val),
              status: 'Awaiting initialization',
              theme: theme,
            ),
            
            const Divider(height: 32, color: Colors.white10),
            
            const SettingsLabel('MANUAL OVERRIDES'),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'FORCE SYNC',
                    icon: Icons.sync,
                    onPressed: _podcastServiceEnabled ? podcastSync.runGlobalSync : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'SCAN ART',
                    icon: Icons.auto_fix_high,
                    onPressed: _artworkServiceEnabled ? () => libraryIndexer.fetchMissingMetadata(persistentLibrary) : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                label: 'RESET DISCOVERY CACHE',
                icon: Icons.delete_sweep_outlined,
                color: Colors.redAccent,
                onPressed: podcastSync.clearCache,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: color != null ? BorderSide(color: color.withValues(alpha: 0.5)) : null,
      ),
    );
  }

  Widget _buildServiceTile({
    required String label,
    required IconData icon,
    required bool isEnabled,
    required bool isProcessing,
    required String status,
    required ValueChanged<bool> onToggle,
    VoidCallback? onPauseResume,
    required ThemeData theme,
  }) {
    final onSurface = theme.colorScheme.onSurface;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isEnabled ? theme.colorScheme.primary : onSurface.withValues(alpha: 0.1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text(
                  isEnabled ? status : 'Service Disabled',
                  style: TextStyle(
                    fontSize: 9, 
                    color: isProcessing ? theme.colorScheme.primary : onSurface.withValues(alpha: 0.38),
                    fontStyle: isProcessing ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (isEnabled) ...[
            if (isProcessing && onPauseResume != null)
              IconButton(
                icon: const Icon(Icons.pause_circle_outline, size: 18),
                onPressed: onPauseResume,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            const SizedBox(width: 8),
          ],
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: theme.colorScheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  String _getIndexerStatus(LibraryIndexerService service) {
    switch (service.state) {
      case IndexerState.hardening: return 'Hardening Metadata (${(service.progress * 100).toInt()}%)';
      case IndexerState.scanning: return 'Scanning Folders...';
      case IndexerState.optimizing: return 'Optimizing Database...';
      case IndexerState.paused: return 'Paused';
      default: return 'Idle';
    }
  }
}
