import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'dart:ui';

class IndexerProgressOverlay extends StatefulWidget {
  final double bottomOffset;

  const IndexerProgressOverlay({
    super.key,
    this.bottomOffset = 16.0,
  });

  @override
  State<IndexerProgressOverlay> createState() => _IndexerProgressOverlayState();
}

class _IndexerProgressOverlayState extends State<IndexerProgressOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indexerService = context.watch<LibraryIndexerService>();
    final theme = Theme.of(context);

    final bool isVisible = indexerService.state != IndexerState.idle;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      right: 16.0,
      bottom: isVisible ? widget.bottomOffset : -100.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isVisible ? 1.0 : 0.0,
        child: GestureDetector(
          key: const Key('indexer_progress_card'),
          onTap: () => _showDetailedSheet(context, indexerService),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Progress indicator or art preview
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: indexerService.progress,
                            strokeWidth: 2,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                          if (indexerService.lastFetchedArt != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                indexerService.lastFetchedArt!,
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            RotationTransition(
                              turns: _rotationController,
                              child: Icon(
                                Icons.sync,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStateLabel(indexerService.state),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            indexerService.statusMessage,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Quick stop/dismiss button
                    IconButton(
                      icon: Icon(
                        Icons.stop_circle_outlined,
                        size: 18,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      onPressed: () {
                        indexerService.stopIndexer();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStateLabel(IndexerState state) {
    switch (state) {
      case IndexerState.scanning:
        return 'SCANNING LIBRARY...';
      case IndexerState.hardening:
        return 'HARDENING METADATA...';
      case IndexerState.optimizing:
        return 'OPTIMIZING DATABASE...';
      case IndexerState.paused:
        return 'SYNC PAUSED';
      case IndexerState.error:
        return 'SYNC ERROR';
      case IndexerState.idle:
        return 'IDLE';
    }
  }

  void _showDetailedSheet(BuildContext context, LibraryIndexerService service) {
    final theme = Theme.of(context);
    final settingsVM = context.read<SettingsViewModel>();
    final lib = context.read<PersistentLibraryService>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: service,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header grab bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BACKGROUND SYNC',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Statistics Telemetry
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TelemetryColumn(
                            label: 'Folders Scanned',
                            value: '${service.foldersScanned}',
                            theme: theme,
                          ),
                          _TelemetryColumn(
                            label: 'Discovered Files',
                            value: '${service.filesDiscovered}',
                            theme: theme,
                          ),
                          _TelemetryColumn(
                            label: 'Total Library Files',
                            value: '${service.totalFilesStored}',
                            theme: theme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: service.progress,
                          minHeight: 6,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Status Description
                      Row(
                        children: [
                          if (service.lastFetchedArt != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                service.lastFetchedArt!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.statusMessage,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getStateDescription(service.state),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(service.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Action controls
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                service.state == IndexerState.scanning
                                    ? service.stopIndexer()
                                    : service.scanLibrary(settingsVM.monitoredFolders, lib);
                              },
                              icon: Icon(
                                service.state == IndexerState.scanning ? Icons.stop : Icons.sync,
                                size: 16,
                              ),
                              label: Text(
                                service.state == IndexerState.scanning ? 'STOP SCAN' : 'SCAN NOW',
                                style: const TextStyle(fontSize: 10),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                service.state == IndexerState.hardening
                                    ? service.stopIndexer()
                                    : service.fetchMissingMetadata(lib);
                              },
                              icon: Icon(
                                service.state == IndexerState.hardening ? Icons.pause : Icons.auto_fix_high_rounded,
                                size: 16,
                              ),
                              label: Text(
                                service.state == IndexerState.hardening ? 'PAUSE FETCH' : 'FETCH ART',
                                style: const TextStyle(fontSize: 10),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getStateDescription(IndexerState state) {
    switch (state) {
      case IndexerState.scanning:
        return 'Searching local folders for audio tracks...';
      case IndexerState.hardening:
        return 'Fetching artist photos, missing cover art, and stitching composite collages...';
      case IndexerState.optimizing:
        return 'Finalizing database indexes for faster lookup...';
      case IndexerState.paused:
        return 'Indexer is paused.';
      case IndexerState.error:
        return 'A failure occurred during synchronization.';
      case IndexerState.idle:
        return 'Synchronization is idle.';
    }
  }
}

class _TelemetryColumn extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _TelemetryColumn({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
