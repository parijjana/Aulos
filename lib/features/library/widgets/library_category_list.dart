import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:provider/provider.dart';
import 'library_art_widget.dart';
import 'library_utils_mixin.dart';

class LibraryCategoryList extends StatelessWidget with LibraryUtilsMixin {
  final LibraryViewModel viewModel;
  final ScrollController scrollController;

  const LibraryCategoryList({
    super.key,
    required this.viewModel,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final queueVM = context.read<QueueViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final items = getAllCategoryItems(viewModel);

    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: LibraryArtWidget(item: item, viewModel: viewModel, size: 40),
          title: Text(
            getCategoryName(item),
            style: TextStyle(color: onSurface),
          ),
          subtitle: getCategorySubtitle(item, theme),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.playlist_add,
                  color: onSurface.withValues(alpha: 0.24),
                  size: 20,
                ),
                onPressed: () async {
                  final tracks = await viewModel.getTracksForItem(item);
                  await queueVM.addAllToQueue(tracks);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.play_circle_outline,
                  color: onSurface.withValues(alpha: 0.24),
                  size: 20,
                ),
                onPressed: () async {
                  final tracks = await viewModel.getTracksForItem(item);
                  if (tracks.isNotEmpty) {
                    await playerVM.setQueueAndPlay(tracks, 0);
                  }
                },
              ),
            ],
          ),
          onTap: () async {
            if (scrollController.hasClients) {
              viewModel.saveScrollOffset(scrollController.offset);
            }
            await viewModel.selectItem(item);
          },
        );
      },
    );
  }
}
