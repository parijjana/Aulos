import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class StorageSection extends StatelessWidget {
  final SettingsViewModel vm;
  final LibraryIndexerService indexerService;
  final bool isDesktop;

  const StorageSection({
    super.key,
    required this.vm,
    required this.indexerService,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'STORAGE',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('LIBRARY SCANNER', theme),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: Scrollbar(child: SingleChildScrollView(child: _buildFolderList(onSurface))),
            ),
            const SizedBox(height: 12),
            _buildScannerControls(context, theme, onSurface),
            const Divider(height: 32, color: Colors.white10),
            _buildSectionHeader('PODCAST RETENTION', theme),
            const SizedBox(height: 16),
            _buildPodcastRetentionSettings(theme, onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFolderList(Color onSurface) {
    if (vm.monitoredFolders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('No folders monitored.', style: TextStyle(color: onSurface.withValues(alpha: 0.24), fontSize: 11)),
        ),
      );
    }

    return Column(
      children: vm.monitoredFolders.map((path) => ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(path, style: TextStyle(color: onSurface.withValues(alpha: 0.7), fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 14),
          onPressed: () => vm.removeMonitoredFolder(path),
        ),
      )).toList(),
    );
  }

  Widget _buildScannerControls(BuildContext context, ThemeData theme, Color onSurface) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final String? path = await FilePicker.getDirectoryPath();
                  if (path != null) vm.addMonitoredFolder(path);
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('ADD FOLDER', style: TextStyle(fontSize: 9)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final lib = context.read<PersistentLibraryService>();
                  indexerService.state == IndexerState.scanning
                      ? indexerService.stopIndexer()
                      : indexerService.scanLibrary(vm.monitoredFolders, lib);
                },
                icon: Icon(indexerService.state == IndexerState.scanning ? Icons.stop : Icons.sync, size: 14),
                label: Text(indexerService.state == IndexerState.scanning ? 'STOP' : 'SCAN', style: const TextStyle(fontSize: 9)),
              ),
            ),
          ],
        ),
        if (indexerService.state != IndexerState.idle) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: indexerService.progress,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 2,
          ),
          const SizedBox(height: 4),
          Text(
            indexerService.statusMessage,
            style: TextStyle(color: onSurface.withValues(alpha: 0.38), fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPodcastRetentionSettings(ThemeData theme, Color onSurface) {
    return Column(
      children: [
        _buildRetentionRow(
          label: 'Keep latest',
          value: vm.podcastKeepCount,
          items: [1, 2, 5, 10, 20, 50],
          suffix: 'episodes',
          onChanged: (val) => vm.setPodcastKeepCount(val!),
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildRetentionRow(
          label: 'Keep for',
          value: vm.podcastKeepDays,
          items: [7, 14, 30, 60, 90],
          suffix: 'days',
          onChanged: (val) => vm.setPodcastKeepDays(val!),
          theme: theme,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DOWNLOAD PATH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                  Text(
                    vm.podcastStorageLocation ?? 'Streaming Only',
                    style: TextStyle(fontSize: 10, color: onSurface.withValues(alpha: 0.38)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.folder_open, size: 18),
              onPressed: () async {
                final path = await FilePicker.getDirectoryPath();
                if (path != null) vm.setPodcastStorageLocation(path);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRetentionRow({
    required String label,
    required int value,
    required List<int> items,
    required String suffix,
    required ValueChanged<int?> onChanged,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: items.contains(value) ? value : items.first,
            items: items.map((i) => DropdownMenuItem(
              value: i,
              child: Text('$i $suffix', style: const TextStyle(fontSize: 11)),
            )).toList(),
            onChanged: onChanged,
            underline: const SizedBox.shrink(),
            isDense: true,
            iconSize: 16,
            dropdownColor: theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }
}
