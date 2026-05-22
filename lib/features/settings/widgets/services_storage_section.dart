import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/features/settings/widgets/settings_shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class ServicesStorageSection extends StatelessWidget {
  final SettingsViewModel vm;
  final ConnectivityViewModel connectivityVM;
  final LibraryIndexerService indexerService;

  const ServicesStorageSection({
    super.key,
    required this.vm,
    required this.connectivityVM,
    required this.indexerService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'SERVICES & STORAGE',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Connectivity Area ---
            _buildConnectivityRow(theme, onSurface),
            if (connectivityVM.isHosting && connectivityVM.sessionSecret != null)
              _buildPinBadge(theme, onSurface),
            
            const Divider(height: 32, color: Colors.white10),
            
            // --- Music Storage Area ---
            const SettingsLabel('LOCAL MUSIC LIBRARIES'),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...vm.monitoredFolders.map((path) => PathSelectorTile(
                      label: 'Music Path',
                      path: path,
                      onTap: () async {
                        final String? newPath = await FilePicker.getDirectoryPath();
                        if (newPath != null) vm.addMonitoredFolder(newPath);
                      },
                      onClear: () => vm.removeMonitoredFolder(path),
                    )),
                    if (vm.monitoredFolders.isEmpty)
                      PathSelectorTile(
                        label: 'Add Music Folder',
                        path: null,
                        onTap: () async {
                          final String? path = await FilePicker.getDirectoryPath();
                          if (path != null) vm.addMonitoredFolder(path);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildScannerControls(context, theme, onSurface),

            const Divider(height: 32, color: Colors.white10),

            // --- Podcast Storage Area ---
            const SettingsLabel('PODCAST DOWNLOADS'),
            PathSelectorTile(
              label: 'Download Path',
              path: vm.podcastStorageLocation,
              onTap: () async {
                final String? path = await FilePicker.getDirectoryPath();
                if (path != null) vm.setPodcastStorageLocation(path);
              },
            ),
            const SizedBox(height: 12),
            _buildRetentionSettings(theme, onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityRow(ThemeData theme, Color onSurface) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsLabel('DEVICE NAME'),
              TextField(
                controller: TextEditingController(text: vm.appName),
                onSubmitted: (val) => vm.setAppName(val),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const SettingsLabel('REMOTE'),
            Switch(
              value: connectivityVM.isHosting,
              onChanged: (val) => val ? connectivityVM.startHosting(deviceName: vm.appName) : connectivityVM.stopHosting(),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinBadge(ThemeData theme, Color onSurface) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 12, color: Colors.white38),
          const SizedBox(width: 8),
          Text(connectivityVM.sessionSecret!, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(width: 12),
          Text('${connectivityVM.localIp}:${connectivityVM.port}', style: TextStyle(color: onSurface.withValues(alpha: 0.24), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildScannerControls(BuildContext context, ThemeData theme, Color onSurface) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              final lib = context.read<PersistentLibraryService>();
              indexerService.state == IndexerState.scanning
                  ? indexerService.stopIndexer()
                  : indexerService.scanLibrary(vm.monitoredFolders, lib);
            },
            icon: Icon(indexerService.state == IndexerState.scanning ? Icons.stop : Icons.sync, size: 14),
            label: Text(indexerService.state == IndexerState.scanning ? 'STOP SCAN' : 'START SCAN', style: const TextStyle(fontSize: 9)),
          ),
        ),
        const SizedBox(width: 8),
        if (indexerService.state != IndexerState.idle)
          Expanded(
            child: Column(
              children: [
                LinearProgressIndicator(value: indexerService.progress, minHeight: 2),
                const SizedBox(height: 4),
                Text(indexerService.statusMessage, style: const TextStyle(fontSize: 8), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRetentionSettings(ThemeData theme, Color onSurface) {
    return Row(
      children: [
        Expanded(
          child: _buildSpinner(
            label: 'KEEP LATEST',
            value: vm.podcastKeepCount,
            items: [1, 2, 5, 10, 20, 50],
            suffix: 'EP',
            onChanged: (val) => vm.setPodcastKeepCount(val!),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSpinner(
            label: 'KEEP FOR',
            value: vm.podcastKeepDays,
            items: [7, 14, 30, 60, 90],
            suffix: 'DAYS',
            onChanged: (val) => vm.setPodcastKeepDays(val!),
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildSpinner({
    required String label,
    required int value,
    required List<int> items,
    required String suffix,
    required ValueChanged<int?> onChanged,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsLabel(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text('$i $suffix', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))).toList(),
            onChanged: onChanged,
            dropdownColor: theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }
}
