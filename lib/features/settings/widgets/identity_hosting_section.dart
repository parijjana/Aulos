import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';

class IdentityHostingSection extends StatelessWidget {
  final SettingsViewModel vm;
  final ConnectivityViewModel connectivityVM;

  const IdentityHostingSection({
    super.key,
    required this.vm,
    required this.connectivityVM,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
