import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/insights_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<InsightsViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Favorites & Insights'),
            backgroundColor: theme.colorScheme.surface,
            scrolledUnderElevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Most Played Tracks'),
                  _buildTopTracksList(context, vm),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader(context, 'Favorite Artists'),
                  _buildFavoriteArtists(context, vm),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Favorite Albums'),
                  _buildFavoriteAlbums(context, vm),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Favorite Podcasts'),
                  _buildFavoritePodcasts(context, vm),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Radio Listening Time'),
                  _buildRadioStats(context, vm),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTopTracksList(BuildContext context, InsightsViewModel vm) {
    return StreamBuilder<List<Track>>(
      stream: vm.topTracks,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'No plays recorded yet.');
        }
        return Column(
          children: snapshot.data!.map((track) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 48,
                  height: 48,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: track.coverArt != null 
                    ? Image.memory(track.coverArt!, fit: BoxFit.cover)
                    : const Icon(Icons.music_note),
                ),
              ),
              title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${track.playCount} plays'),
              trailing: IconButton(
                icon: Icon(
                  track.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: track.isFavorite ? Colors.red : null,
                ),
                onPressed: () => vm.toggleTrackFavorite(track),
              ),
              onTap: () => context.read<PlayerViewModel>().loadTrack(track),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFavoriteArtists(BuildContext context, InsightsViewModel vm) {
    return StreamBuilder<List<Artist>>(
      stream: vm.favoriteArtists,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'Add artists to favorites.');
        }
        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final artist = snapshot.data![index];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: artist.photo != null ? MemoryImage(artist.photo!) : null,
                    child: artist.photo == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      artist.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoriteAlbums(BuildContext context, InsightsViewModel vm) {
     return StreamBuilder<List<Album>>(
      stream: vm.favoriteAlbums,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'Add albums to favorites.');
        }
        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final album = snapshot.data![index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: album.coverArt != null 
                        ? Image.memory(album.coverArt!, fit: BoxFit.cover)
                        : const Icon(Icons.album, size: 60),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: Text(
                      album.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoritePodcasts(BuildContext context, InsightsViewModel vm) {
    return StreamBuilder<List<Podcast>>(
      stream: vm.favoritePodcasts,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'Add podcasts to favorites.');
        }
        return Column(
          children: snapshot.data!.map((podcast) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: podcast.image != null 
                    ? Image.memory(podcast.image!, fit: BoxFit.cover)
                    : const Icon(Icons.podcasts),
                ),
              ),
              title: Text(podcast.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(podcast.author ?? 'Unknown Author'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRadioStats(BuildContext context, InsightsViewModel vm) {
    return StreamBuilder<List<RadioListeningStat>>(
      stream: vm.radioStats,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'Listen to radio to see stats.');
        }
        return Column(
          children: snapshot.data!.map((stat) {
            final minutes = stat.timeSpentSeconds ~/ 60;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Station: ${stat.stationUuid}'), // UUID for now, ideally join with RadioStation table
              subtitle: Text('Listening time: $minutes minutes'),
              leading: const Icon(Icons.radio),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
