import 'package:flutter/material.dart';
import 'dart:io';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/features/settings/widgets/settings_shared.dart';
import 'package:aulos/core/storage/storage_directory_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              constraints: const BoxConstraints(maxHeight: 140),
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
            const SizedBox(height: 8),
            _buildScannerControls(context, theme, onSurface, 0),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUTO-SYNC FOLDERS',
                        style: TextStyle(
                          fontSize: 8,
                          color: onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Automatically sync library when files change in background',
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: vm.isFolderWatcherEnabled,
                  onChanged: (val) => vm.setIsFolderWatcherEnabled(val),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),

            const Divider(height: 32, color: Colors.white10),

            // --- Audiobook Storage Area ---
            const SettingsLabel('LOCAL AUDIOBOOK LIBRARIES'),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...vm.audiobookFolders.map((path) => PathSelectorTile(
                      label: 'Book Path',
                      path: path,
                      onTap: () async {
                        final String? newPath = await FilePicker.getDirectoryPath();
                        if (newPath != null) vm.addAudiobookFolder(newPath);
                      },
                      onClear: () => vm.removeAudiobookFolder(path),
                    )),
                    if (vm.audiobookFolders.isEmpty)
                      PathSelectorTile(
                        label: 'Add Audiobook Folder',
                        path: null,
                        onTap: () async {
                          final String? path = await FilePicker.getDirectoryPath();
                          if (path != null) vm.addAudiobookFolder(path);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildScannerControls(context, theme, onSurface, 1),

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
            _buildRetentionSettings(theme, onSurface),
            const SizedBox(height: 16),
            const SettingsLabel('PODCASTINDEX API CREDENTIALS'),
            const SizedBox(height: 8),
            _PodcastIndexCredentialsInputs(vm: vm, theme: theme, onSurface: onSurface),

            const Divider(height: 32, color: Colors.white10),

            // --- Radio Database Area ---
            const SettingsLabel('RADIO DISCOVERY CACHE'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final radioVM = context.read<RadioViewModel>();
                      _showConfirmClear(context, radioVM);
                    },
                    icon: const Icon(Icons.delete_sweep_outlined, size: 14),
                    label: const Text('CLEAN RADIO CACHE', style: TextStyle(fontSize: 9)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent.withValues(alpha: 0.7),
                      side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Removes cached discovery results. Your favorites are preserved.',
              style: TextStyle(fontSize: 8, color: onSurface.withValues(alpha: 0.24)),
            ),

            const Divider(height: 32, color: Colors.white10),

            // --- Database Path Area ---
            const SettingsLabel('DATABASE STORAGE MODE'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: vm.isPortableMode
                  ? 'portable'
                  : (vm.customDatabaseDirectory != null ? 'custom' : 'default'),
              style: TextStyle(color: onSurface, fontSize: 13),
              dropdownColor: theme.colorScheme.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'default', child: Text('AppData (Default)')),
                DropdownMenuItem(value: 'portable', child: Text('Portable (App Folder)')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Directory...')),
              ],
              onChanged: (String? value) async {
                if (value == null) return;

                final prefs = await SharedPreferences.getInstance();
                final manager = StorageDirectoryManager(prefs);

                if (value == 'default') {
                  try {
                    final defaultPath = await manager.getDefaultSupportDirectoryPath();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restoring databases to default, please wait...')),
                    );
                    await manager.migrateDatabases(defaultPath);
                    await manager.setPortableMode(false);
                    await vm.setCustomDatabaseDirectory(null);
                    vm.setPortableMode(false);
                    _showRestartDialog(context);
                  } catch (e) {
                    _showError(context, e);
                  }
                } else if (value == 'portable') {
                  try {
                    final canWrite = await manager.canEnablePortableMode();
                    if (!canWrite) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Permission denied to write next to application executable.')),
                      );
                      return;
                    }
                    final exeDir = File(Platform.resolvedExecutable).parent;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configuring portable mode, please wait...')),
                    );
                    await manager.migrateDatabases(exeDir.path);
                    await manager.setPortableMode(true);
                    await vm.setCustomDatabaseDirectory(null);
                    vm.setPortableMode(true);
                    _showRestartDialog(context);
                  } catch (e) {
                    _showError(context, e);
                  }
                } else if (value == 'custom') {
                  final String? newPath = await FilePicker.getDirectoryPath();
                  if (newPath != null) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Moving databases, please wait...')),
                      );
                      await manager.migrateDatabases(newPath);
                      await manager.setPortableMode(false);
                      await vm.setCustomDatabaseDirectory(newPath);
                      vm.setPortableMode(false);
                      _showRestartDialog(context);
                    } catch (e) {
                      _showError(context, e);
                    }
                  }
                }
              },
            ),
            if (vm.customDatabaseDirectory != null) ...[
              const SizedBox(height: 12),
              PathSelectorTile(
                label: 'Custom Folder',
                path: vm.customDatabaseDirectory,
                onTap: () async {
                  final String? newPath = await FilePicker.getDirectoryPath();
                  if (newPath != null) {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final manager = StorageDirectoryManager(prefs);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Moving databases, please wait...')),
                      );
                      await manager.migrateDatabases(newPath);
                      await vm.setCustomDatabaseDirectory(newPath);
                      _showRestartDialog(context);
                    } catch (e) {
                      _showError(context, e);
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmClear(BuildContext context, RadioViewModel vm) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Radio Cache?'),
        content: const Text('This will delete all discovered stations and categories. Your favorite stations in the library will not be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              vm.clearRadioCache();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Radio cache cleared.')),
              );
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
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

  Widget _buildScannerControls(BuildContext context, ThemeData theme, Color onSurface, int folderType) {
    // Only show progress if THIS SPECIFIC folder type is being scanned
    final bool isThisTypeScanning = indexerService.state == IndexerState.scanning && indexerService.scanningFolderType == folderType;
    final bool isAnyScanning = indexerService.state == IndexerState.scanning;
    
    final folders = folderType == 1 ? vm.audiobookFolders : vm.monitoredFolders;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isAnyScanning && !isThisTypeScanning ? null : () {
              final lib = context.read<PersistentLibraryService>();
              isThisTypeScanning
                  ? indexerService.stopIndexer()
                  : indexerService.scanLibrary(folders, lib, folderType: folderType);
            },
            icon: Icon(isThisTypeScanning ? Icons.stop : Icons.sync, size: 14),
            label: Text(isThisTypeScanning ? 'STOP SCAN' : 'START SCAN', style: const TextStyle(fontSize: 9)),
          ),
        ),
        const SizedBox(width: 8),
        if (isThisTypeScanning || (indexerService.state == IndexerState.optimizing && indexerService.scanningFolderType == folderType))
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

  void _showRestartDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Required'),
        content: const Text('Database files have been successfully migrated. Please restart Aulos to apply.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error migrating database: $error')),
    );
  }
}

class _PodcastIndexCredentialsInputs extends StatefulWidget {
  final SettingsViewModel vm;
  final ThemeData theme;
  final Color onSurface;

  const _PodcastIndexCredentialsInputs({
    required this.vm,
    required this.theme,
    required this.onSurface,
  });

  @override
  State<_PodcastIndexCredentialsInputs> createState() => _PodcastIndexCredentialsInputsState();
}

class _PodcastIndexCredentialsInputsState extends State<_PodcastIndexCredentialsInputs> {
  late TextEditingController _keyController;
  late TextEditingController _secretController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.vm.podcastIndexApiKey ?? '');
    _secretController = TextEditingController(text: widget.vm.podcastIndexApiSecret ?? '');
  }

  @override
  void dispose() {
    _keyController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _save() {
    widget.vm.setPodcastIndexCredentials(
      _keyController.text.trim(),
      _secretController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _keyController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: 'API KEY',
            labelStyle: TextStyle(color: widget.onSurface.withValues(alpha: 0.38), fontSize: 10),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          onChanged: (_) => _save(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _secretController,
          style: const TextStyle(fontSize: 12),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'API SECRET',
            labelStyle: TextStyle(color: widget.onSurface.withValues(alpha: 0.38), fontSize: 10),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          onChanged: (_) => _save(),
        ),
      ],
    );
  }
}
