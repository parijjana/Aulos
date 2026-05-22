import 'package:flutter/material.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';

class DiagnosticsSection extends StatelessWidget {
  final ConnectivityViewModel vm;
  final bool isDesktop;

  const DiagnosticsSection({
    super.key,
    required this.vm,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}
