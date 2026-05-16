import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';

mixin LibraryUtilsMixin {
  int getCategoryId(dynamic item) {
    if (item is int) return item;
    if (item is Track) return item.id;
    if (item is Folder) return item.id;
    if (item is Album) return item.id;
    if (item is Artist) return item.id;
    return (item as dynamic).id as int;
  }

  String getCategoryName(dynamic item) {
    if (item is int) return item.toString();
    if (item is Track) return item.title;
    return (item as dynamic).name as String;
  }

  String getCategoryGridSubtitle(dynamic item) {
    if (item is Folder) return item.path;
    if (item is Artist) return 'Artist';
    if (item is Album) return 'Album';
    if (item is Track) return 'Track';
    return '';
  }

  Widget? getCategorySubtitle(dynamic item, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    if (item is Folder) {
      return Text(
        item.path,
        style: TextStyle(color: onSurface, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (item is Track) {
      return Text(
        item.path,
        style: TextStyle(color: onSurface, fontSize: 10),
        maxLines: 1,
      );
    }
    return null;
  }

  List<dynamic> getAllCategoryItems(LibraryViewModel vm) {
    switch (vm.mode) {
      case LibraryMode.folders:
        return vm.folders;
      case LibraryMode.artists:
        return vm.artists;
      case LibraryMode.albums:
        return vm.albums;
      case LibraryMode.genres:
        return vm.genres;
      case LibraryMode.years:
        return vm.years;
      case LibraryMode.playlists:
        return vm.playlists;
    }
  }

  List<dynamic> getCombinedItems(LibraryViewModel vm) {
    final List<dynamic> combined = [];
    combined.addAll(vm.subFolders);
    combined.addAll(vm.subAlbums);
    combined.addAll(vm.tracks);
    return combined;
  }

  Widget buildActionCircle({
    required IconData icon,
    required VoidCallback onTap,
    double size = 32,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.6),
      ),
    );
  }
}
