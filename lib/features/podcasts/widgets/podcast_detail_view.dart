import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';
import 'podcast_info_pane.dart';
import 'podcast_episode_list.dart';
import 'podcast_notes_pane.dart';

class PodcastDetailView extends StatefulWidget {
  final Podcast podcast;
  final VoidCallback onBack;

  const PodcastDetailView({
    super.key,
    required this.podcast,
    required this.onBack,
  });

  @override
  State<PodcastDetailView> createState() => _PodcastDetailViewState();
}

class _PodcastDetailViewState extends State<PodcastDetailView> {
  Episode? _selectedEpisode;

  @override
  Widget build(BuildContext context) {
    final podcastVM = context.watch<PodcastViewModel>();
    final playerVM = context.read<PlayerViewModel>();
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
                          Tab(text: 'EPISODES'),
                          Tab(text: 'NOTES & CLIPS'),
                        ],
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: TabBarView(
                          children: [
                            PodcastInfoPane(
                              width: null, // Full width
                              podcast: widget.podcast,
                              onUnsubscribe: () {
                                podcastVM.unsubscribe(widget.podcast.id);
                                widget.onBack();
                              },
                            ),
                            PodcastEpisodeList(
                              episodes: podcastVM.episodes,
                              selectedEpisode: _selectedEpisode,
                              onEpisodeSelected: (ep) => setState(() => _selectedEpisode = ep),
                            ),
                            PodcastNotesPane(
                              selectedEpisode: _selectedEpisode,
                              onTogglePin: (ep) {
                                podcastVM.togglePin(ep);
                                setState(() {
                                  _selectedEpisode = ep.copyWith(isPinned: !ep.isPinned);
                                });
                              },
                              onPlay: (ep) => podcastVM.playEpisode(ep, playerVM),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Row(
                children: [
                  PodcastInfoPane(
                    podcast: widget.podcast,
                    onUnsubscribe: () {
                      podcastVM.unsubscribe(widget.podcast.id);
                      widget.onBack();
                    },
                  ),
                  VerticalDivider(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  Expanded(
                    flex: 4,
                    child: PodcastEpisodeList(
                      episodes: podcastVM.episodes,
                      selectedEpisode: _selectedEpisode,
                      onEpisodeSelected: (ep) => setState(() => _selectedEpisode = ep),
                    ),
                  ),
                  VerticalDivider(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  Expanded(
                    flex: 5,
                    child: PodcastNotesPane(
                      selectedEpisode: _selectedEpisode,
                      onTogglePin: (ep) {
                        podcastVM.togglePin(ep);
                        setState(() {
                          _selectedEpisode = ep.copyWith(isPinned: !ep.isPinned);
                        });
                      },
                      onPlay: (ep) => podcastVM.playEpisode(ep, playerVM),
                    ),
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
            'PODCASTS',
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
              widget.podcast.title.toUpperCase(),
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
