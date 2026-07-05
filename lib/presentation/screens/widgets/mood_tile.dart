import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Uint8List? coverArt;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool hasData;

  const MoodTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.coverArt,
    this.imageUrl,
    required this.onTap,
    this.hasData = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasData && coverArt != null)
                Image.memory(coverArt!, fit: BoxFit.cover)
              else if (hasData && imageUrl != null)
                Image.network(imageUrl!, fit: BoxFit.cover)
              else
                Center(
                  child: Icon(
                    icon,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                
              if (hasData)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.surface.withValues(alpha: 0.9),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasData ? 'LAST PLAYED' : 'TAP TO BROWSE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
