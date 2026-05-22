import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/domain/network/discovery_service.dart';

class NetworkSection extends StatelessWidget {
  final ConnectivityViewModel vm;
  final SettingsViewModel settingsVM;
  final bool isDesktop;

  const NetworkSection({
    super.key,
    required this.vm,
    required this.settingsVM,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
