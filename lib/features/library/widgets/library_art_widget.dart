import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:provider/provider.dart';

class LibraryArtWidget extends StatelessWidget {
  final dynamic item;
  final double? size;
  final LibraryViewModel viewModel;

  const LibraryArtWidget({
    super.key,
    required this.item,
    required this.viewModel,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final isCircle = settingsVM.artworkShape == settings.ArtworkShape.circle;

    Uint8List? art;
    if (item is Album) {
      art = (item as Album).coverArt;
    } else if (item is Track) {
      final t = item as Track;
      art = t.coverArt ?? viewModel.getArtForTrack(trackId: t.id);
    } else if (item is Artist) {
      art = (item as Artist).photo;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: isCircle ? null : BorderRadius.circular(size == null ? 12 : 4),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        image: art != null && art.isNotEmpty
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : null,
      ),
      child: art == null || art.isEmpty
          ? Center(
              child: _getCategoryIcon(
                viewModel.mode,
                theme,
                size: size == null ? 64 : 20,
              ),
            )
          : null,
    );
  }

  static Widget _getCategoryIcon(
    LibraryMode mode,
    ThemeData theme, {
    double size = 24,
  }) {
    IconData icon;
    switch (mode) {
      case LibraryMode.folders:
        icon = Icons.folder;
        break;
      case LibraryMode.artists:
        icon = Icons.person;
        break;
      case LibraryMode.albums:
        icon = Icons.album;
        break;
      case LibraryMode.genres:
        icon = Icons.category;
        break;
      case LibraryMode.years:
        icon = Icons.calendar_today;
        break;
      case LibraryMode.playlists:
        icon = Icons.playlist_play;
        break;
    }
    return Icon(
      icon,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
      size: size,
    );
  }
}
