import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

import 'package:aulos/presentation/viewmodels/playlist_view_model.dart';

class QueueTab extends StatelessWidget {
  const QueueTab({super.key});

  void _showSavePlaylistDialog(
    BuildContext context,
    QueueViewModel queueVM,
    PlaylistViewModel playlistVM,
  ) {
    final controller = TextEditingController(text: 'New Playlist');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Save Queue as Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            labelStyle: TextStyle(color: Colors.cyanAccent),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await playlistVM.saveQueueAsPlaylist(
                  controller.text,
                  queueVM.currentQueue,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final queueVM = context.watch<QueueViewModel>();
    final playerVM = context.watch<PlayerViewModel>();
    final playlistVM = context.read<PlaylistViewModel>();

    if (queueVM.currentQueue.isEmpty) {
      return const Center(
        child: Text(
          'Queue is empty',
          style: TextStyle(color: Colors.white38, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${queueVM.currentQueue.length} TRACKS',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _showSavePlaylistDialog(context, queueVM, playlistVM),
                    icon: const Icon(
                      Icons.playlist_add,
                      color: Colors.cyanAccent,
                    ),
                    label: const Text(
                      'SAVE AS PLAYLIST',
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: queueVM.clearQueue,
                    icon: const Icon(Icons.clear_all, color: Colors.redAccent),
                    label: const Text(
                      'CLEAR',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: queueVM.currentQueue.length,
            onReorder: queueVM.moveTrack,
            itemBuilder: (context, index) {
              final track = queueVM.currentQueue[index];
              final isPlaying = queueVM.currentIndex == index;

              return Dismissible(
                key: ValueKey('queue_dismiss_${track.id}_$index'),
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
                onDismissed: (_) => queueVM.removeFromQueue(index),
                child: ListTile(
                  key: ValueKey('queue_${track.id}_$index'),
                  leading: isPlaying
                      ? const Icon(
                          Icons.play_circle_filled,
                          color: Colors.cyanAccent,
                        )
                      : const Icon(Icons.music_note, color: Colors.white30),
                  title: Text(
                    track.title,
                    style: TextStyle(
                      color: isPlaying ? Colors.cyanAccent : Colors.white,
                      fontWeight: isPlaying
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: const Text(
                    'Unknown Artist',
                    style: TextStyle(color: Colors.white38),
                  ),
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.white24),
                  ),
                  onTap: () => playerVM.playTrackAtIndex(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
