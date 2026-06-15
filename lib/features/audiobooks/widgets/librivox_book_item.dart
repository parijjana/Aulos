import 'package:flutter/material.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';

class LibriVoxBookItem extends StatelessWidget {
  final LibriVoxBook book;
  final LibraryViewModel libraryVM;
  final LibriVoxViewModel vm;

  const LibriVoxBookItem({
    super.key,
    required this.book,
    required this.libraryVM,
    required this.vm,
  });

  BoxDecoration _buildCoverDecoration(ThemeData theme, double hue, bool isSelected) {
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
        color: isSelected
            ? theme.colorScheme.primary
            : accentColor.withOpacity(0.25),
        width: isSelected ? 2.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.45)
              : Colors.black.withValues(alpha: 0.35),
          blurRadius: isSelected ? 16 : 8,
          spreadRadius: isSelected ? 1 : 0,
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

    final bool isDownloaded = libraryVM.books.any((b) => b.librivoxId == book.id && b.isDownloadedViaAulos);
    final bool isStreaming = libraryVM.books.any((b) => b.librivoxId == book.id && !b.isDownloadedViaAulos);
    final double? progress = vm.downloadProgress[book.id];
    final bool isSelected = vm.selectedBook?.id == book.id;

    return GestureDetector(
      onTap: () {
        vm.selectBook(book);
        final isWide = MediaQuery.of(context).size.width >= 720;
        if (!isWide) {
          DefaultTabController.maybeOf(context)?.animateTo(1);
        }
      },
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.68,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: _buildCoverDecoration(theme, hue, isSelected),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Spine crease
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 12,
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
                      left: 12,
                      right: 12,
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
                    // Title and Author
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 10, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            book.authorNames,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 9,
                              fontStyle: FontStyle.italic,
                              shadows: const [
                                Shadow(
                                  blurRadius: 2,
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
                    // Progress and badges
                    if (progress != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else if (isDownloaded)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(Icons.download_done_rounded, color: Colors.teal, size: 14),
                      )
                    else if (isStreaming)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(Icons.sensors_rounded, color: Colors.orange, size: 14),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
