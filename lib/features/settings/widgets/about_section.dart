import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      title: 'ABOUT',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aulos Audio v1.2.0', style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('High-performance private sync.', style: TextStyle(color: onSurface.withValues(alpha: 0.38), fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
