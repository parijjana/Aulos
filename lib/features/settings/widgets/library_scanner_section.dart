import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class LibraryScannerSection extends StatelessWidget {
  final SettingsViewModel vm;
  final LibraryIndexerService indexerService;
  final bool isDesktop;

  const LibraryScannerSection({
    super.key,
    required this.vm,
    required this.indexerService,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final listWidget = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vm.monitoredFolders.length,
      itemBuilder: (context, index) {
        final path = vm.monitoredFolders[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            path,
            style:
                TextStyle(color: onSurface.withValues(alpha: 0.7), fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Colors.redAccent, size: 18),
            onPressed: () => vm.removeMonitoredFolder(path),
          ),
        );
      },
    );

    final Widget scannerContent = Column(
      children: [
        if (isDesktop)
          Expanded(
            child: vm.monitoredFolders.isEmpty
                ? Center(
                    child: Text(
                      'No folders monitored.',
                      style: TextStyle(
                          color: onSurface.withValues(alpha: 0.24),
                          fontSize: 12),
                    ),
                  )
                : SingleChildScrollView(child: listWidget),
          )
        else if (vm.monitoredFolders.isNotEmpty)
          listWidget,
        const Divider(color: Colors.black12, height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TelemetryItem(
                      label: 'Folders', count: indexerService.foldersScanned),
                  _TelemetryItem(
                      label: 'Total Files',
                      count: indexerService.totalFilesStored),
                ],
              ),
              const SizedBox(height: 16),
              if (indexerService.state != IndexerState.idle) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: indexerService.progress,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(indexerService.progress * 100).toInt()}%',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (indexerService.lastFetchedArt != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          indexerService.lastFetchedArt!,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        indexerService.statusMessage,
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final String? path =
                            await FilePicker.getDirectoryPath();
                        if (path != null) vm.addMonitoredFolder(path);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('ADD FOLDER',
                          style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final lib = context.read<PersistentLibraryService>();
                        indexerService.state == IndexerState.scanning
                            ? indexerService.stopIndexer()
                            : indexerService.scanLibrary(
                                vm.monitoredFolders, lib);
                      },
                      icon: Icon(
                          indexerService.state == IndexerState.scanning
                              ? Icons.stop
                              : Icons.sync,
                          size: 16),
                      label: Text(
                          indexerService.state == IndexerState.scanning
                              ? 'STOP'
                              : 'SCAN',
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final lib = context.read<PersistentLibraryService>();
                    indexerService.fetchMissingMetadata(lib);
                  },
                  icon: Icon(
                    indexerService.state == IndexerState.hardening
                        ? Icons.hourglass_empty
                        : Icons.auto_fix_high_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    indexerService.state == IndexerState.hardening
                        ? 'HARDENING...'
                        : 'FETCH MISSING ART & PHOTOS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: indexerService.rebuildFromScratch,
                child: const Text(
                  'WIPE & REBUILD DATABASE',
                  style: TextStyle(color: Colors.redAccent, fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return GlassCard(
      title: 'LIBRARY SCANNER',
      fullHeight: isDesktop,
      child: scannerContent,
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final String label;
  final int count;
  const _TelemetryItem({required this.label, required this.count});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.24), fontSize: 8, fontWeight: FontWeight.bold)),
        Text(count.toString(), style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
