import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:provider/provider.dart';
import 'library_art_widget.dart';
import 'library_utils_mixin.dart';

class LibraryGridView extends StatelessWidget with LibraryUtilsMixin {
  final LibraryViewModel viewModel;
  final ScrollController scrollController;

  const LibraryGridView({
    super.key,
    required this.viewModel,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final queueVM = context.read<QueueViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final combined = viewModel.isAtRoot
        ? getAllCategoryItems(viewModel)
        : getCombinedItems(viewModel);

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        return GestureDetector(
          onTap: () async {
            if (scrollController.hasClients) {
              viewModel.saveScrollOffset(scrollController.offset);
            }
            await viewModel.selectItem(item);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'cat_${getCategoryId(item)}',
                      child: LibraryArtWidget(item: item, viewModel: viewModel),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildActionCircle(
                            icon: Icons.playlist_add,
                            onTap: () async {
                              final tracks = await viewModel.getTracksForItem(item);
                              await queueVM.addAllToQueue(tracks);
                            },
                          ),
                          const SizedBox(width: 8),
                          buildActionCircle(
                            icon: Icons.play_arrow,
                            onTap: () async {
                              final tracks = await viewModel.getTracksForItem(item);
                              if (tracks.isNotEmpty) {
                                await playerVM.setQueueAndPlay(tracks, 0);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                getCategoryName(item),
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                getCategoryGridSubtitle(item),
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.38),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
