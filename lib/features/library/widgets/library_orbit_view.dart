import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/obsidian_orbit.dart';
import 'package:provider/provider.dart';
import 'library_art_widget.dart';
import 'library_utils_mixin.dart';

class LibraryOrbitView extends StatelessWidget with LibraryUtilsMixin {
  final LibraryViewModel viewModel;

  const LibraryOrbitView({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final queueVM = context.read<QueueViewModel>();
    final theme = Theme.of(context);

    final combined = viewModel.isAtRoot
        ? getAllCategoryItems(viewModel)
        : getCombinedItems(viewModel);

    return AulosOrbit(
      items: combined,
      itemBuilder: (item) => AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LibraryArtWidget(item: item, viewModel: viewModel),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildActionCircle(
                      icon: Icons.playlist_add,
                      size: 40,
                      onTap: () async {
                        final tracks = await viewModel.getTracksForItem(item);
                        await queueVM.addAllToQueue(tracks);
                      },
                    ),
                    const SizedBox(height: 12),
                    buildActionCircle(
                      icon: Icons.play_arrow,
                      size: 40,
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Text(
                    getCategoryName(item),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (item) async => await viewModel.selectItem(item),
    );
  }
}
