import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';
import 'audiobook_clips_pane.dart';
import 'package:aulos/presentation/widgets/wikipedia_knowledge_dialog.dart';

class AudiobookDetailView extends StatefulWidget {
  final Album book;
  final VoidCallback onBack;

  const AudiobookDetailView({
    super.key,
    required this.book,
    required this.onBack,
  });

  @override
  State<AudiobookDetailView> createState() => _AudiobookDetailViewState();
}

class _AudiobookDetailViewState extends State<AudiobookDetailView> {
  @override
  Widget build(BuildContext context) {
    final libraryVM = context.watch<LibraryViewModel>();
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildBreadcrumb(theme),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 900;
              
              if (isNarrow) {
                return DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                        tabs: const [
                          Tab(text: 'INFO'),
                          Tab(text: 'CHAPTERS'),
                          Tab(text: 'SAVED CLIPS'),
                        ],
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _AudiobookInfoPane(book: widget.book),
                            _AudiobookChaptersPane(tracks: libraryVM.tracks),
                            AudiobookClipsPane(book: widget.book),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _AudiobookInfoPane(book: widget.book),
                  ),
                  VerticalDivider(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  Expanded(
                    flex: 4,
                    child: _AudiobookChaptersPane(tracks: libraryVM.tracks),
                  ),
                  VerticalDivider(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  Expanded(
                    flex: 3,
                    child: AudiobookClipsPane(book: widget.book),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 8),
          Text(
            'BOOKS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
          const Icon(Icons.chevron_right, size: 14, color: Colors.white24),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.book.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AudiobookInfoPane extends StatelessWidget {
  final Album book;
  const _AudiobookInfoPane({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryVM = context.watch<LibraryViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Art
          Center(
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    image: book.coverArt != null 
                        ? DecorationImage(image: MemoryImage(book.coverArt!), fit: BoxFit.cover)
                        : (book.coverArtUrl != null ? DecorationImage(image: NetworkImage(book.coverArtUrl!), fit: BoxFit.cover) : null),
                  ),
                  child: (book.coverArt == null && book.coverArtUrl == null)
                      ? Icon(Icons.library_books, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.1))
                      : null,
                ),
                if (libraryVM.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            book.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          // AUTHOR / SERIES
          if (book.subtitle != null && book.subtitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      book.subtitle!,
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    onPressed: () {
                      WikipediaKnowledgeDialog.show(
                        context,
                        book.subtitle!,
                        subtitle: 'Author Wiki',
                        fallbackIcon: Icons.menu_book_rounded,
                      );
                    },
                    tooltip: 'Wikipedia Author Info',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'BY ${book.narrator ?? "UNKNOWN NARRATOR"}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ),
              if (book.narrator != null)
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  onPressed: () {
                    WikipediaKnowledgeDialog.show(
                      context,
                      book.narrator!,
                      subtitle: 'Narrator Wiki',
                      fallbackIcon: Icons.record_voice_over_rounded,
                    );
                  },
                  tooltip: 'Wikipedia Narrator Info',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          if (book.seriesName != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'SERIES: ${book.seriesName}${book.seriesPosition != null ? " #${book.seriesPosition}" : ""}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: libraryVM.isLoading ? null : () => libraryVM.enrichAudiobook(book),
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('ENRICH METADATA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'DESCRIPTION',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white24),
          ),
          const SizedBox(height: 8),
          Text(
            book.description ?? 'No description available for this book yet. Click "Enrich Metadata" to fetch details from Audnexus.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
          ),
          if (book.artistId != null && libraryVM.libraryService is PersistentLibraryServiceImpl)
            FutureBuilder<AudiobookArtist?>(
              future: () async {
                final db = (libraryVM.libraryService as PersistentLibraryServiceImpl).audiobookDb;
                return (db.select(db.audiobookArtists)..where((a) => a.id.equals(book.artistId!))).getSingleOrNull();
              }(),
              builder: (context, snapshot) {
                final artist = snapshot.data;
                if (artist == null || artist.bio == null || artist.bio!.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'ABOUT THE AUTHOR',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      artist.bio!,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
                    ),
                  ],
                );
              },
            ),
          if (book.publisher != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'PUBLISHED BY ${book.publisher!.toUpperCase()}',
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white10, letterSpacing: 1.0),
              ),
            ),
        ],
      ),
    );
  }
}

class _AudiobookChaptersPane extends StatelessWidget {
  final List<Track> tracks;
  const _AudiobookChaptersPane({required this.tracks});

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final libraryVM = context.watch<LibraryViewModel>();
    final playbackPositions = libraryVM.trackPlaybackPositions;
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isPlaying = playerVM.currentTrack?.id == track.id;
        final positionMs = playbackPositions[track.id] ?? 0;
        final durationSec = track.durationSeconds ?? 0;
        
        return ListTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPlaying ? theme.colorScheme.primary : Colors.white10,
            ),
            child: Center(
              child: isPlaying 
                ? const Icon(Icons.play_arrow, size: 16, color: Colors.white)
                : Text('${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          title: Text(
            track.title,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
              color: isPlaying ? theme.colorScheme.primary : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (track.durationSeconds != null)
                Text(_formatDuration(Duration(seconds: track.durationSeconds!)), style: const TextStyle(fontSize: 10)),
              if (positionMs > 0 && durationSec > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (positionMs / 1000) / durationSec,
                      minHeight: 3,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPlaying ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => playerVM.setQueueAndPlay(tracks, index),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
