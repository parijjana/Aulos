import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:provider/provider.dart';

import '../widgets/ui_section.dart';
import '../widgets/services_storage_section.dart';
import '../widgets/logs_about_section.dart';
import '../widgets/services_dashboard_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settingsVM = context.watch<SettingsViewModel>();
    final connectivityVM = context.watch<ConnectivityViewModel>();
    final indexerService = context.watch<LibraryIndexerService>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 1100;
        
        if (!isDesktop) {
          return _buildMobileLayout(settingsVM, connectivityVM, indexerService);
        } else {
          return _buildDesktopLayout(settingsVM, connectivityVM, indexerService);
        }
      },
    );
  }

  Widget _buildMobileLayout(
    SettingsViewModel vm,
    ConnectivityViewModel connectivityVM,
    LibraryIndexerService service,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          UiSection(vm: vm),
          const SizedBox(height: 16),
          const ServicesDashboardSection(),
          const SizedBox(height: 16),
          ServicesStorageSection(vm: vm, connectivityVM: connectivityVM, indexerService: service),
          const SizedBox(height: 16),
          SizedBox(
            height: 500,
            child: LogsAboutSection(isDesktop: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    SettingsViewModel vm,
    ConnectivityViewModel connectivityVM,
    LibraryIndexerService service,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1: UI & Services Overview
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  UiSection(vm: vm),
                  const SizedBox(height: 20),
                  const ServicesDashboardSection(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Column 2: Storage & Connectivity
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: ServicesStorageSection(vm: vm, connectivityVM: connectivityVM, indexerService: service),
            ),
          ),
          const SizedBox(width: 20),
          // Column 3: System Logs
          Expanded(
            flex: 4,
            child: LogsAboutSection(isDesktop: true),
          ),
        ],
      ),
    );
  }
}
