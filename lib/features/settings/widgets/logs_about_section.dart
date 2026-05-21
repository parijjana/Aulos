import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:provider/provider.dart';

class LogsAboutSection extends StatelessWidget {
  final bool isDesktop;

  const LogsAboutSection({
    super.key,
    required this.isDesktop,
    dynamic vm,
  });

  @override
  Widget build(BuildContext context) {
    final logService = context.watch<MediaLogService>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    // Join logs into a single string for SelectableText
    final logBuffer = logService.logs.take(1000).toList().reversed.join('\n');

    return GlassCard(
      title: 'SYSTEM LOGS',
      fullHeight: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 8),
                const Flexible(child: Text('AULOS CORE v1.2.0', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                const Spacer(),
                TextButton(
                  onPressed: logService.clear,
                  child: const Text('CLEAR', style: TextStyle(fontSize: 9, color: Colors.redAccent)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black, // Pure black for better contrast
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              // SelectionArea at the top of the scrollable content
              child: SelectionArea(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      logBuffer,
                      style: const TextStyle(
                        color: Colors.greenAccent, 
                        fontSize: 9, 
                        fontFamily: 'monospace', 
                        height: 1.4,
                      ),
                      // Ensure selection is enabled
                      enableInteractiveSelection: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  'Highlight text to copy. Persisted to aulos.log',
                  style: TextStyle(fontSize: 8, color: onSurface.withValues(alpha: 0.24)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'High-performance private audio sync engine.',
                  style: TextStyle(fontSize: 8, color: onSurface.withValues(alpha: 0.12)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
