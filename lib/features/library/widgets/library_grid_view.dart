import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:provider/provider.dart';
import 'package:aulos/data/database/app_database.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              viewModel.loadMore();
            }
            return false;
          },
          child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
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
                        if ((item is Artist && item.isFavorite) || (item is Album && item.isFavorite))
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 14,
                              ),
                            ),
                          ),
                        if (item is Album && item.isAudiobook)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              child: LinearProgressIndicator(
                                value: viewModel.getBookProgress(item.id),
                                minHeight: 4,
                                backgroundColor: Colors.black38,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                              ),
                            ),
                          ),
                        if (item is Album && item.librivoxId != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (item.isDownloadedViaAulos)
                                    ? Colors.teal.withValues(alpha: 0.9)
                                    : Colors.orange.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.isDownloadedViaAulos ? Icons.download_done_rounded : Icons.sensors_rounded,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.isDownloadedViaAulos ? 'OFFLINE' : 'STREAM',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
        ));
      }
    );
  }
}
