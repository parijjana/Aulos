import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';
import 'library_art_widget.dart';
import 'library_utils_mixin.dart';

class LibrarySubList extends StatelessWidget with LibraryUtilsMixin {
  final LibraryViewModel viewModel;
  final ScrollController scrollController;

  const LibrarySubList({
    super.key,
    required this.viewModel,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final combined = getCombinedItems(viewModel);

    return ListView.builder(
      controller: scrollController,
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        if (item is Track) {
          return ListTile(
            leading: LibraryArtWidget(item: item, viewModel: viewModel, size: 40),
            title: Text(item.title, style: TextStyle(color: onSurface)),
            subtitle: Text(
              item.path,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.38),
                fontSize: 10,
              ),
              maxLines: 1,
            ),
            onTap: () async {
              await playerVM.setQueueAndPlay(
                viewModel.tracks,
                viewModel.tracks.indexOf(item),
              );
            },
          );
        }
        return ListTile(
          leading: LibraryArtWidget(item: item, viewModel: viewModel, size: 40),
          title: Text(
            getCategoryName(item),
            style: TextStyle(color: onSurface),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: onSurface.withValues(alpha: 0.24),
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
