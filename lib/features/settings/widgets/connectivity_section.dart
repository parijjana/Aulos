import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/domain/network/discovery_service.dart';

class ConnectivitySection extends StatelessWidget {
  final SettingsViewModel vm;
  final ConnectivityViewModel connectivityVM;

  const ConnectivitySection({
    super.key,
    required this.vm,
    required this.connectivityVM,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'SERVICES & NETWORK',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEVICE NAME', style: _labelStyle(onSurface)),
                      _DeviceNameField(vm: vm),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text('REMOTE CONTROL', style: _labelStyle(onSurface)),
                    Switch(
                      value: connectivityVM.isHosting,
                      onChanged: (val) {
                        if (val) {
                          connectivityVM.startHosting(deviceName: vm.appName);
                        } else {
                          connectivityVM.stopHosting();
                        }
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            if (connectivityVM.isHosting && connectivityVM.sessionSecret != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('PIN: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(
                      connectivityVM.sessionSecret!,
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'IP: ${connectivityVM.localIp ?? "..."}:${connectivityVM.port}',
                      style: TextStyle(color: onSurface.withValues(alpha: 0.38), fontSize: 9, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 32, color: Colors.white10),
            Row(
              children: [
                Text('HOST DISCOVERY', style: _labelStyle(onSurface)),
                const Spacer(),
                TextButton.icon(
                  onPressed: connectivityVM.isScanning ? connectivityVM.stopDiscovery : connectivityVM.startDiscovery,
                  icon: connectivityVM.isScanning 
                    ? const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.search, size: 14),
                  label: Text(connectivityVM.isScanning ? 'SCANNING...' : 'SCAN', style: const TextStyle(fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDeviceList(connectivityVM, theme, onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(ConnectivityViewModel connectivityVM, ThemeData theme, Color onSurface) {
    if (connectivityVM.discoveredDevices.isEmpty && connectivityVM.connectedDevices.isEmpty && !connectivityVM.isScanning) {
      return Center(child: Text('No devices found.', style: TextStyle(color: onSurface.withValues(alpha: 0.24), fontSize: 10)));
    }

    return Column(
      children: [
        ...connectivityVM.discoveredDevices.map((d) => _DeviceTile(device: d, vm: connectivityVM, settingsVM: vm)),
        ...connectivityVM.connectedDevices.map((d) => ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(d['name'] ?? 'Remote', style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.link, color: Colors.greenAccent, size: 14),
        )),
      ],
    );
  }

  TextStyle _labelStyle(Color onSurface) => TextStyle(
    color: onSurface.withValues(alpha: 0.38),
    fontSize: 8,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
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
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
      onChanged: (val) => widget.vm.setAppName(val),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final DiscoveredDevice device; 
  final ConnectivityViewModel vm; 
  final SettingsViewModel settingsVM;

  const _DeviceTile({required this.device, required this.vm, required this.settingsVM});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(device.name, style: const TextStyle(fontSize: 11)),
      subtitle: Text(device.ip, style: const TextStyle(fontSize: 9)),
      trailing: const Icon(Icons.chevron_right, size: 12),
      onTap: () => _showSecretDialog(context, theme: Theme.of(context)),
    );
  }

  void _showSecretDialog(BuildContext context, {required ThemeData theme}) {
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
