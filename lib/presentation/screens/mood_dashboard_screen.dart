import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/presentation/viewmodels/mood_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'widgets/mood_tile.dart';

class MoodDashboardScreen extends StatelessWidget {
  const MoodDashboardScreen({super.key});

  void _navigateToBrowseTab(BuildContext context, int tabIndex) {
    final displayVM = context.read<DisplayViewModel>();
    if (displayVM.mode == UIContextMode.minimalist) {
      displayVM.setMode(UIContextMode.highContext);
    }
    displayVM.setTabIndex(tabIndex);
  }

  void _navigateToNowPlaying(BuildContext context) {
    final displayVM = context.read<DisplayViewModel>();
    if (displayVM.mode == UIContextMode.minimalist) {
      displayVM.setMode(UIContextMode.highContext);
    }
    displayVM.setTabIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodVM = context.watch<MoodViewModel>();
    final playerVM = context.read<PlayerViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'What are we in the mood to listen to?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: moodVM.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;
                            final double availableHeight = constraints.maxHeight;
                            final double aspectRatio = availableWidth / availableHeight;

                            final tiles = [
                              _buildTile(
                                context: context,
                                data: moodVM.lastMusic,
                                fallbackTitle: 'Music',
                                fallbackSubtitle: 'Your local library',
                                icon: Icons.music_note_rounded,
                                onTap: () {
                                  if (moodVM.lastMusic?.track != null) {
                                    final queueVM = context.read<QueueViewModel>();
                                    final index = queueVM.currentQueue.indexWhere((t) => t.id == moodVM.lastMusic!.track!.id);
                                    if (index != -1) {
                                      playerVM.playTrackAtIndex(index);
                                    } else {
                                      playerVM.loadTrack(moodVM.lastMusic!.track!, isAvailable: true);
                                    }
                                    _navigateToNowPlaying(context);
                                  } else {
                                    _navigateToBrowseTab(context, 1); // Music
                                  }
                                },
                              ),
                              _buildTile(
                                context: context,
                                data: moodVM.lastPodcast,
                                fallbackTitle: 'Podcasts',
                                fallbackSubtitle: 'Latest episodes',
                                icon: Icons.podcasts_rounded,
                                onTap: () {
                                  if (moodVM.lastPodcast?.track != null) {
                                    playerVM.loadTrack(
                                      moodVM.lastPodcast!.track!,
                                      description: moodVM.lastPodcast!.description,
                                      artistName: moodVM.lastPodcast!.track!.title,
                                      albumName: moodVM.lastPodcast!.subtitle,
                                      imageUrl: moodVM.lastPodcast!.imageUrl,
                                      isAvailable: true,
                                    );
                                    _navigateToNowPlaying(context);
                                  } else {
                                    _navigateToBrowseTab(context, 2); // Podcast
                                  }
                                },
                              ),
                              _buildTile(
                                context: context,
                                data: moodVM.lastAudiobook,
                                fallbackTitle: 'Audiobooks',
                                fallbackSubtitle: 'Continue listening',
                                icon: Icons.book_rounded,
                                onTap: () {
                                  if (moodVM.lastAudiobook?.track != null) {
                                    final queueVM = context.read<QueueViewModel>();
                                    final index = queueVM.currentQueue.indexWhere((t) => t.id == moodVM.lastAudiobook!.track!.id);
                                    if (index != -1) {
                                      playerVM.playTrackAtIndex(index);
                                    } else {
                                      playerVM.loadTrack(moodVM.lastAudiobook!.track!, isAvailable: true);
                                    }
                                    _navigateToNowPlaying(context);
                                  } else {
                                    _navigateToBrowseTab(context, 3); // Audiobook
                                  }
                                },
                              ),
                              _buildTile(
                                context: context,
                                data: moodVM.lastNoise,
                                fallbackTitle: 'Ambient Noise',
                                fallbackSubtitle: 'Focus and relax',
                                icon: Icons.waves_rounded,
                                onTap: () {
                                  if (moodVM.lastNoise?.noiseMix != null) {
                                    final noiseVM = context.read<NoiseViewModel>();
                                    noiseVM.playMix(moodVM.lastNoise!.noiseMix!);
                                    _navigateToNowPlaying(context);
                                  } else {
                                    _navigateToBrowseTab(context, 5); // Ambient Noise
                                  }
                                },
                              ),
                              _buildTile(
                                context: context,
                                data: moodVM.lastRadio,
                                fallbackTitle: 'Radio',
                                fallbackSubtitle: 'Live stations',
                                icon: Icons.radio_rounded,
                                onTap: () {
                                  if (moodVM.lastRadio?.track != null) {
                                    playerVM.loadTrack(moodVM.lastRadio!.track!, isAvailable: true);
                                    _navigateToNowPlaying(context);
                                  } else {
                                    _navigateToBrowseTab(context, 4); // Radio
                                  }
                                },
                              ),
                            ];

                            if (aspectRatio > 1.4) {
                              // Horizontal layout (Landscape)
                              final double gridWidth = availableWidth - 48;
                              final double tileWidth = (gridWidth - 64) / 5;
                              final double tileHeight = availableHeight - 32;
                              final double targetHeight = tileHeight.clamp(80.0, 180.0);
                              final double targetWidth = tileWidth.clamp(80.0, 200.0);

                              return Center(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: targetWidth * 5 + 64 + 48,
                                    maxHeight: targetHeight + 32,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: tiles.map((tile) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: tile,
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              );
                            } else if (aspectRatio < 0.7) {
                              // Vertical layout (Portrait)
                              return ListView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                children: tiles.map((tile) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: SizedBox(
                                    height: 100, // Fixed height for portrait list
                                    child: tile,
                                  ),
                                )).toList(),
                              );
                            } else {
                              // Squarish grid layout (Default)
                              final double gridWidth = availableWidth - 48;
                              final double tileWidth = (gridWidth - 16) / 2;
                              final double tileHeight = (availableHeight - 32) / 3;

                              final double targetHeight = tileHeight.clamp(80.0, 150.0);
                              final double targetWidth = tileWidth.clamp(100.0, 220.0);
                              final double computedAspectRatio = targetWidth / targetHeight;

                              return Center(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: targetWidth * 2 + 16 + 48,
                                    maxHeight: targetHeight * 3 + 32 + 32,
                                  ),
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                    mainAxisSpacing: 16.0,
                                    crossAxisSpacing: 16.0,
                                    childAspectRatio: computedAspectRatio,
                                    children: tiles,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required MoodItemData? data,
    required String fallbackTitle,
    required String fallbackSubtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    if (data == null) {
      return MoodTile(
        title: fallbackTitle,
        subtitle: fallbackSubtitle,
        icon: icon,
        hasData: false,
        onTap: onTap,
      );
    }

    return MoodTile(
      title: data.title,
      subtitle: data.subtitle,
      icon: icon,
      coverArt: data.coverArt,
      imageUrl: data.imageUrl,
      hasData: true,
      onTap: onTap,
    );
  }
}
