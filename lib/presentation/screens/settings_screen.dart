import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/domain/network/discovery_service.dart';
import 'package:localaudioplayer/data/library/library_indexer_service.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    final connectivityVM = context.watch<ConnectivityViewModel>();
    final indexerService = context.watch<LibraryIndexerService>();
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 1100;
        final bool isShort = constraints.maxHeight < 600;

        if (!constraints.hasBoundedHeight || (isDesktop && isShort) || !isDesktop) {
          return _buildMobileLayout(context, settingsVM, connectivityVM, indexerService, theme);
        } else {
          return _buildDesktopLayout(context, settingsVM, connectivityVM, indexerService, theme);
        }
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    SettingsViewModel vm,
    ConnectivityViewModel connectivityVM,
    LibraryIndexerService service,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildIdentityHostingSection(context, vm, connectivityVM, theme),
          const SizedBox(height: 16),
          _buildNetworkSection(context, connectivityVM, vm, theme, isDesktop: false),
          const SizedBox(height: 16),
          _buildScannerSection(context, vm, service, theme, isDesktop: false),
          const SizedBox(height: 16),
          _buildThemeSection(context, vm, theme, isDesktop: false),
          const SizedBox(height: 16),
          _buildEffectsSection(context, vm, theme),
          const SizedBox(height: 16),
          _buildDiagnosticsSection(context, connectivityVM, theme, isDesktop: false),
          const SizedBox(height: 16),
          _buildAboutSection(theme),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    SettingsViewModel vm,
    ConnectivityViewModel connectivityVM,
    LibraryIndexerService service,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Identity & Network
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildIdentityHostingSection(context, vm, connectivityVM, theme),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildNetworkSection(context, connectivityVM, vm, theme, isDesktop: true),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Middle Column: Library & Appearance
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: _buildScannerSection(context, vm, service, theme, isDesktop: true),
                ),
                const SizedBox(height: 16),
                _buildThemeSection(context, vm, theme, isDesktop: true),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column: Effects, Diagnostics & About
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildEffectsSection(context, vm, theme),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildDiagnosticsSection(context, connectivityVM, theme, isDesktop: true),
                ),
                const SizedBox(height: 16),
                _buildAboutSection(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Identity & Hosting
  Widget _buildIdentityHostingSection(
    BuildContext context,
    SettingsViewModel vm,
    ConnectivityViewModel connectivityVM,
    ThemeData theme,
  ) {
    final onSurface = theme.colorScheme.onSurface;
    return GlassCard(
      title: 'IDENTITY & HOSTING',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DEVICE NAME',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.38),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _DeviceNameField(vm: vm),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                'Allow Remote Control',
                style: TextStyle(color: onSurface, fontSize: 13),
              ),
              value: connectivityVM.isHosting,
              onChanged: (val) {
                if (val) {
                  connectivityVM.startHosting(deviceName: vm.appName);
                } else {
                  connectivityVM.stopHosting();
                }
              },
              activeThumbColor: theme.colorScheme.primary,
            ),
            if (connectivityVM.isHosting && connectivityVM.sessionSecret != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      'CONNECTION PIN',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.38),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        connectivityVM.sessionSecret!,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'IP: ${connectivityVM.localIp ?? "..."}:${connectivityVM.port}',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.24),
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 2. Network Discovery & Remotes
  Widget _buildNetworkSection(
    BuildContext context,
    ConnectivityViewModel vm,
    SettingsViewModel settingsVM,
    ThemeData theme, {
    required bool isDesktop,
  }) {
    final onSurface = theme.colorScheme.onSurface;

    final Widget listContent = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shrinkWrap: !isDesktop,
      physics: isDesktop ? null : const NeverScrollableScrollPhysics(),
      children: [
        if (vm.discoveredDevices.isNotEmpty) ...[
          _buildSectionHeader(theme, 'DISCOVERED'),
          ...vm.discoveredDevices.map((device) => ListTile(
                dense: true,
                leading: Icon(Icons.devices,
                    color: theme.colorScheme.primary, size: 18),
                title: Text(device.name,
                    style: TextStyle(color: onSurface, fontSize: 12)),
                subtitle: Text(device.ip,
                    style: TextStyle(
                        color: onSurface.withValues(alpha: 0.38), fontSize: 10)),
                trailing: const Icon(Icons.chevron_right, size: 14),
                onTap: () =>
                    _handleDeviceTap(context, vm, settingsVM, device, theme),
              )),
        ],
        if (vm.connectedDevices.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionHeader(theme, 'CONNECTED'),
          ...vm.connectedDevices.map((device) => ListTile(
                dense: true,
                leading: Icon(Icons.phone_android,
                    color: onSurface.withValues(alpha: 0.38), size: 18),
                title: Text(device['name'] ?? 'Unknown',
                    style: TextStyle(color: onSurface, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.link_off,
                      color: Colors.redAccent, size: 16),
                  onPressed: () => vm.banDevice(device['id'] ?? ''),
                ),
              )),
        ],
        if (vm.discoveredDevices.isEmpty &&
            vm.connectedDevices.isEmpty &&
            !vm.isScanning)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No devices found.',
                style: TextStyle(
                    color: onSurface.withValues(alpha: 0.24), fontSize: 11),
              ),
            ),
          ),
      ],
    );

    return GlassCard(
      title: 'NETWORK & REMOTES',
      fullHeight: isDesktop,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        vm.isScanning ? vm.stopDiscovery : vm.startDiscovery,
                    icon: vm.isScanning
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.search, size: 16),
                    label: Text(
                      vm.isScanning ? 'SCANNING...' : 'SCAN FOR HOSTS',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isDesktop ? Expanded(child: listContent) : listContent,
          const Divider(color: Colors.black12, height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Manual Connect (IP:PORT)',
                hintStyle: TextStyle(
                    fontSize: 11, color: onSurface.withValues(alpha: 0.24)),
                suffixIcon:
                    Icon(Icons.add, color: theme.colorScheme.primary, size: 18),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (val) => vm.connectByUrl(val),
              style: TextStyle(color: onSurface, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Library Scanner
  Widget _buildScannerSection(
    BuildContext context,
    SettingsViewModel vm,
    LibraryIndexerService indexerService,
    ThemeData theme, {
    required bool isDesktop,
  }) {
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

  // 4. Appearance
  Widget _buildThemeSection(
    BuildContext context,
    SettingsViewModel vm,
    ThemeData theme, {
    required bool isDesktop,
  }) {
    final onSurface = theme.colorScheme.onSurface;
    return GlassCard(
      title: 'APPEARANCE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'THEME PRESET',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.38),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: vm.availableThemes.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final t = vm.availableThemes[index];
                final isSelected = vm.themeModel.name == t.name;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => vm.setTheme(t),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? theme.colorScheme.primary : onSurface.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.palette, color: isSelected ? theme.colorScheme.primary : onSurface.withValues(alpha: 0.24)),
                          const SizedBox(height: 4),
                          Text(t.name, style: TextStyle(fontSize: 10, color: onSurface), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.black12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'ARTWORK SHAPE',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.38),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<ArtworkShape>(
                        title: const Text('Squares', style: TextStyle(fontSize: 12)),
                        value: ArtworkShape.square,
                        groupValue: vm.artworkShape,
                        onChanged: (val) => val != null ? vm.setArtworkShape(val) : null,
                        dense: true,
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<ArtworkShape>(
                        title: const Text('Circles', style: TextStyle(fontSize: 12)),
                        value: ArtworkShape.circle,
                        groupValue: vm.artworkShape,
                        onChanged: (val) => val != null ? vm.setArtworkShape(val) : null,
                        dense: true,
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.black12),
          _buildPodcastSettings(context, vm, theme, isDesktop: isDesktop),
        ],
      ),
    );
  }

  Widget _buildPodcastSettings(
    BuildContext context,
    SettingsViewModel vm,
    ThemeData theme, {
    required bool isDesktop,
  }) {
    final onSurface = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'PODCASTS',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.38),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('Storage Location', style: TextStyle(fontSize: 13)),
          subtitle: Text(
            vm.podcastStorageLocation ?? 'Not Set (Streaming Only)',
            style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.5)),
          ),
          trailing: const Icon(Icons.folder_open_outlined, size: 20),
          onTap: () async {
            final path = await FilePicker.getDirectoryPath();
            if (path != null) {
              vm.setPodcastStorageLocation(path);
            }
          },
        ),
        SwitchListTile(
          title: const Text('Auto-Download New', style: TextStyle(fontSize: 13)),
          subtitle: Text(
            'Automatically download the latest episode upon subscription',
            style: TextStyle(fontSize: 10, color: onSurface.withValues(alpha: 0.38)),
          ),
          value: vm.autoDownloadNewEpisodes,
          onChanged: vm.setAutoDownloadNewEpisodes,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildEffectsSection(BuildContext context, SettingsViewModel vm, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;
    return GlassCard(
      title: 'VISUAL EFFECTS',
      child: Column(
        children: [
          SwitchListTile(
            dense: true,
            title: Text('Host Glow', style: TextStyle(color: onSurface, fontSize: 12)),
            value: vm.showHostAnimation,
            onChanged: (val) => vm.setShowHostAnimation(val),
          ),
          SwitchListTile(
            dense: true,
            title: Text('Remote Glow', style: TextStyle(color: onSurface, fontSize: 12)),
            value: vm.showRemoteAnimation,
            onChanged: (val) => vm.setShowRemoteAnimation(val),
          ),
        ],
      ),
    );
  }

  // 5. Diagnostics & About
  Widget _buildDiagnosticsSection(
    BuildContext context,
    ConnectivityViewModel vm,
    ThemeData theme, {
    required bool isDesktop,
  }) {
    final onSurface = theme.colorScheme.onSurface;

    final Widget logView = Container(
      width: double.infinity,
      height: isDesktop ? null : 200, // Fixed height on mobile, flexible on desktop
      padding: const EdgeInsets.all(12),
      color: Colors.black26,
      child: ListView.builder(
        reverse: true,
        shrinkWrap: !isDesktop,
        itemCount: vm.logs.length,
        itemBuilder: (context, index) => Text(
          vm.logs[index],
          style: const TextStyle(
              color: Colors.greenAccent, fontSize: 9, fontFamily: 'monospace'),
        ),
      ),
    );

    return GlassCard(
      title: 'DIAGNOSTICS',
      fullHeight: isDesktop,
      child: Column(
        children: [
          isDesktop ? Expanded(child: logView) : logView,
          TextButton(
            onPressed: vm.clearLogs,
            child: Text('CLEAR LOGS',
                style: TextStyle(
                    fontSize: 9, color: onSurface.withValues(alpha: 0.38))),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;
    return GlassCard(
      title: 'ABOUT',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aulos Audio v1.2.0', style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('High-performance private sync.', style: TextStyle(color: onSurface.withValues(alpha: 0.38), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _handleDeviceTap(BuildContext context, ConnectivityViewModel vm, SettingsViewModel settingsVM, DiscoveredDevice device, ThemeData theme) {
    final savedToken = vm.getSavedToken(device.name);
    if (savedToken != null) {
      vm.connectTo(device, '', deviceId: settingsVM.deviceId, deviceName: settingsVM.appName);
      return;
    }
    _showSecretDialog(context, vm, settingsVM, device, theme);
  }

  void _showSecretDialog(BuildContext context, ConnectivityViewModel vm, SettingsViewModel settingsVM, DiscoveredDevice device, ThemeData theme) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Enter PIN'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(letterSpacing: 8.0, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              vm.connectTo(device, controller.text, deviceId: settingsVM.deviceId, deviceName: settingsVM.appName);
              Navigator.pop(context);
            },
            child: const Text('CONNECT'),
          ),
        ],
      ),
    );
  }
}

class _DeviceNameField extends StatefulWidget {
  final SettingsViewModel vm;
  const _DeviceNameField({required this.vm});
  @override
  State<_DeviceNameField> createState() => _DeviceNameFieldState();
}

class _DeviceNameFieldState extends State<_DeviceNameField> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.vm.appName);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
      onChanged: (val) => widget.vm.setAppName(val),
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
