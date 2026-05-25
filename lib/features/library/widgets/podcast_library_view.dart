import 'package:flutter/material.dart';
import 'package:aulos/features/podcasts/widgets/podcast_detail_view.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/data/database/app_database.dart' as app_db;
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class PodcastLibraryView extends StatefulWidget {
  const PodcastLibraryView({super.key});

  @override
  State<PodcastLibraryView> createState() => _PodcastLibraryViewState();
}

class _PodcastLibraryViewState extends State<PodcastLibraryView> {
  final ScrollController _tabScrollController = ScrollController();

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastVM = context.watch<PodcastViewModel>();
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final activePod = podcastVM.activePodcast;
    if (activePod != null) {
      return PodcastDetailView(
        podcast: activePod,
        onBack: () => podcastVM.setActivePodcast(null),
      );
    }

    return Column(
      children: [
        // SUB-BAR: CATEGORIES & SEARCH
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _tabScrollController,
                    thumbVisibility: true,
                    thickness: 2,
                    radius: const Radius.circular(2),
                    child: SingleChildScrollView(
                      controller: _tabScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          _buildFilterPill('ALL SHOWS', podcastVM.libraryFilter == 'ALL SHOWS', theme, () => podcastVM.setLibraryFilter('ALL SHOWS')),
                          const SizedBox(width: 8),
                          _buildFilterPill('RECENT', podcastVM.libraryFilter == 'RECENT', theme, () => podcastVM.setLibraryFilter('RECENT')),
                          const SizedBox(width: 8),
                          _buildFilterPill('DOWNLOADED', podcastVM.libraryFilter == 'DOWNLOADED', theme, () => podcastVM.setLibraryFilter('DOWNLOADED')),
                        ],
                      ),
                    ),
                  ),
                ),
                _ExpandableSearch(viewModel: podcastVM),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: podcastVM.filteredPodcasts.isEmpty 
            ? _buildEmptyState(onSurface)
            : _buildMainContent(podcastVM, settingsVM, theme, onSurface),
        ),
      ],
    );
  }

  Widget _buildMainContent(PodcastViewModel podcastVM, settings.SettingsViewModel settingsVM, ThemeData theme, Color onSurface) {
    final list = podcastVM.filteredPodcasts;
    if (settingsVM.libraryViewType == settings.LibraryViewType.list) {
      return ListView.builder(
        key: const PageStorageKey('podcast_library_list'),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final pod = list[index];
          return ListTile(
            leading: _buildMiniArt(pod.imageUrl),
            title: Text(pod.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(pod.author ?? 'Unknown Author', style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.38))),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => podcastVM.setActivePodcast(pod),
          );
        },
      );
    }

    return GridView.builder(
      key: const PageStorageKey('podcast_library_grid'),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.85,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final pod = list[index];
        return _buildPodcastGridTile(pod, theme, podcastVM);
      },
    );
  }

  Widget _buildFilterPill(String label, bool isActive, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastGridTile(app_db.Podcast pod, ThemeData theme, PodcastViewModel vm) {
    return GestureDetector(
      onTap: () => vm.setActivePodcast(pod),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: pod.imageUrl != null 
                  ? Image.network(
                      pod.imageUrl!, 
                      fit: BoxFit.cover, 
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), child: const Icon(Icons.podcasts, size: 48)),
                    )
                  : Container(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), child: const Icon(Icons.podcasts, size: 48)),
            ),
          ),
          const SizedBox(height: 12),
          Text(pod.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(pod.author ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
        ],
      ),
    );
  }

  Widget _buildMiniArt(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: url != null 
          ? Image.network(
              url, 
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.podcasts, size: 20, color: Colors.white24),
            ) 
          : const Icon(Icons.podcasts, size: 20, color: Colors.white24),
      ),
    );
  }

  Widget _buildEmptyState(Color onSurface) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.podcasts_outlined, size: 64, color: onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('No podcasts found.', style: TextStyle(color: onSurface.withValues(alpha: 0.38))),
        ],
      ),
    );
  }
}

class _ExpandableSearch extends StatefulWidget {
  final PodcastViewModel viewModel;
  const _ExpandableSearch({required this.viewModel});

  @override
  State<_ExpandableSearch> createState() => _ExpandableSearchState();
}

class _ExpandableSearchState extends State<_ExpandableSearch> {
  bool _expanded = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _expanded ? 200 : 40,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.search, size: 18, color: _expanded ? theme.colorScheme.primary : null),
            onPressed: () {
              setState(() => _expanded = !_expanded);
              if (!_expanded) {
                _controller.clear();
              } else {
                _focusNode.requestFocus();
              }
            },
          ),
          if (_expanded)
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search library...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                onSubmitted: (val) {
                },
              ),
            ),
        ],
      ),
    );
  }
}
