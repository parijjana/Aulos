import 'package:flutter/material.dart';
import 'package:aulos/domain/library/librivox_book.dart';

class LibriVoxBookCover extends StatelessWidget {
  final LibriVoxBook book;

  const LibriVoxBookCover({
    super.key,
    required this.book,
  });

  BoxDecoration _buildCoverDecoration(ThemeData theme, double hue) {
    final startColor = HSLColor.fromAHSL(1.0, hue, 0.65, 0.22).toColor();
    final endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.75, 0.12).toColor();
    final accentColor = HSLColor.fromAHSL(1.0, hue, 0.9, 0.6).toColor();

    return BoxDecoration(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(3),
        bottomLeft: Radius.circular(3),
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      ),
      border: Border.all(
        color: accentColor.withOpacity(0.25),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 8,
          offset: const Offset(3, 3),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hash = book.title.hashCode;
    final double hue = (hash.abs() % 360).toDouble();

    return SizedBox(
      height: 140,
      child: AspectRatio(
        aspectRatio: 0.68,
        child: Container(
          decoration: _buildCoverDecoration(theme, hue),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Spine crease
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 10,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Top decorative neon strip
              Positioned(
                top: 0,
                left: 10,
                right: 10,
                height: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: HSLColor.fromAHSL(1.0, hue, 0.9, 0.6).toColor().withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                    boxShadow: [
                      BoxShadow(
                        color: HSLColor.fromAHSL(1.0, hue, 0.9, 0.6).toColor().withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              // Glossy sheen overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-0.8, -1.0),
                        end: const Alignment(0.8, 1.0),
                        stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white.withOpacity(0.06),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Title and Author text
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black45,
                            offset: Offset(0.5, 0.5),
                          ),
                        ],
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      book.authorNames,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 7,
                        fontStyle: FontStyle.italic,
                        shadows: const [
                          Shadow(
                            blurRadius: 1.5,
                            color: Colors.black38,
                            offset: Offset(0.5, 0.5),
                          ),
                        ],
                      ),
                      maxLines: 2,
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
