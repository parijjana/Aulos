import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/data/library/library_indexer_service.dart';
import 'package:provider/provider.dart';

import '../widgets/identity_hosting_section.dart';
import '../widgets/network_section.dart';
import '../widgets/library_scanner_section.dart';
import '../widgets/appearance_section.dart';
import '../widgets/effects_section.dart';
import '../widgets/diagnostics_section.dart';
import '../widgets/about_section.dart';

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
          IdentityHostingSection(vm: vm, connectivityVM: connectivityVM),
          const SizedBox(height: 16),
          NetworkSection(vm: connectivityVM, settingsVM: vm, isDesktop: false),
          const SizedBox(height: 16),
          LibraryScannerSection(vm: vm, indexerService: service, isDesktop: false),
          const SizedBox(height: 16),
          AppearanceSection(vm: vm, isDesktop: false),
          const SizedBox(height: 16),
          EffectsSection(vm: vm),
          const SizedBox(height: 16),
          DiagnosticsSection(vm: connectivityVM, isDesktop: false),
          const SizedBox(height: 16),
          const AboutSection(),
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
                IdentityHostingSection(vm: vm, connectivityVM: connectivityVM),
                const SizedBox(height: 16),
                Expanded(
                  child: NetworkSection(vm: connectivityVM, settingsVM: vm, isDesktop: true),
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
                  child: LibraryScannerSection(vm: vm, indexerService: service, isDesktop: true),
                ),
                const SizedBox(height: 16),
                AppearanceSection(vm: vm, isDesktop: true),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column: Effects, Diagnostics & About
          Expanded(
            flex: 3,
            child: Column(
              children: [
                EffectsSection(vm: vm),
                const SizedBox(height: 16),
                Expanded(
                  child: DiagnosticsSection(vm: connectivityVM, isDesktop: true),
                ),
                const SizedBox(height: 16),
                const AboutSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
