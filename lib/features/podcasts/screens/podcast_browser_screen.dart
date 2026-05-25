import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/features/podcasts/screens/podcast_detail_screen.dart';
import 'package:provider/provider.dart';

class PodcastBrowserScreen extends StatefulWidget {
  const PodcastBrowserScreen({super.key});

  @override
  State<PodcastBrowserScreen> createState() => _PodcastBrowserScreenState();
}

class _PodcastBrowserScreenState extends State<PodcastBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _detailScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  bool _isSearching = false;
  bool _searchExpanded = false;

  final List<Map<String, dynamic>> _discoveryCategories = [
    {'name': 'Technology', 'id': '1318', 'icon': Icons.computer},
    {'name': 'Business', 'id': '1311', 'icon': Icons.business},
    {'name': 'Science', 'id': '1321', 'icon': Icons.science},
    {'name': 'Comedy', 'id': '1303', 'icon': Icons.sentiment_very_satisfied},
    {'name': 'Health', 'id': '1315', 'icon': Icons.health_and_safety},
    {'name': 'True Crime', 'id': '1488', 'icon': Icons.gavel},
  ];

  @override
  void initState() {
    super.initState();
    final podcastVM = context.read<PodcastViewModel>();
    podcastVM.loadCategoryPreviews(_discoveryCategories);
    _detailScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    if (_detailScrollController.position.pixels >= _detailScrollController.position.maxScrollExtent - 200) {
      final vm = context.read<PodcastViewModel>();
      if (vm.isLoading) return;

      final selectedCategory = vm.selectedDiscoveryCategory;
      if (selectedCategory != null) {
        final catId = selectedCategory['id'] as String;
        final currentCount = vm.categoryResults[catId]?.length ?? 0;
        vm.loadMoreForCategory(catId, currentCount);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _detailScrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastVM = context.watch<PodcastViewModel>();
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (podcastVM.activeDiscoveryDetail == null)
            _buildSubBar(podcastVM, theme),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildBody(podcastVM, settingsVM, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubBar(PodcastViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            // 1. SCROLLABLE CATEGORIES
            Expanded(
              child: Scrollbar(
                controller: _categoryScrollController,
                thumbVisibility: true,
                thickness: 2,
                radius: const Radius.circular(2),
                child: SingleChildScrollView(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      if (vm.selectedDiscoveryCategory != null || _isSearching)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 14),
                          onPressed: () {
                            vm.setSelectedDiscoveryCategory(null);
                            setState(() {
                              _isSearching = false;
                              _searchExpanded = false;
                              _searchController.clear();
                            });
                          },
                        ),
                      ..._discoveryCategories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterPill(
                          cat['name'] as String, 
                          vm.selectedDiscoveryCategory?['id'] == cat['id'], 
                          theme,
                          () => _onCategorySelected(cat),
                        ),
                      )).toList(),
                      const SizedBox(width: 24), // Buffer
                    ],
                  ),
                ),
              ),
            ),

            // 2. EXPANDABLE SEARCH
            _ExpandableSearch(
              controller: _searchController,
              focusNode: _searchFocus,
              expanded: _searchExpanded,
              onToggle: (val) => setState(() => _searchExpanded = val),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  setState(() => _isSearching = true);
                  vm.search(val);
                }
              },
              onClear: () {
                setState(() {
                  _isSearching = false;
                  _searchExpanded = false;
                  _searchController.clear();
                });
              },
            ),
          ],
        ),
      ),
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
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(PodcastViewModel vm, settings.SettingsViewModel settingsVM, ThemeData theme) {
    if (vm.activeDiscoveryDetail != null) {
      return const PodcastDetailScreen();
    }

    if (vm.selectedDiscoveryCategory != null) {
      return _buildCategoryDetailView(vm, settingsVM, theme);
    }

    if (_isSearching) {
      return _buildSearchResults(vm, theme);
    }

    return RefreshIndicator(
      onRefresh: vm.refreshDiscovery,
      child: ListView(
        children: [
          _buildTrendingShelf(vm, theme),
          ..._discoveryCategories.map((cat) => _buildCategoryShelf(cat, vm, theme)).toList(),
        ],
      ),
    );
  }

  void _onCategorySelected(Map<String, dynamic> cat) {
    context.read<PodcastViewModel>().setSelectedDiscoveryCategory(cat);
  }

  Widget _buildTrendingShelf(PodcastViewModel vm, ThemeData theme) {
    final results = vm.trendingResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'TRENDING'),
        SizedBox(
          height: 220,
          child: results.isEmpty 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildDiscoveryGridItem(item, theme, vm),
                  );
                },
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryShelf(Map<String, dynamic> cat, PodcastViewModel vm, ThemeData theme) {
    final results = vm.categoryResults[cat['id']] ?? [];
    if (results.isEmpty && !vm.isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(theme, (cat['name'] as String).toUpperCase()),
            TextButton(
              onPressed: () => _onCategorySelected(cat),
              child: const Text('SEE ALL', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
        SizedBox(
          height: 220,
          child: results.isEmpty 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildDiscoveryGridItem(item, theme, vm),
                  );
                },
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryDetailView(PodcastViewModel vm, settings.SettingsViewModel settingsVM, ThemeData theme) {
    final catId = vm.selectedDiscoveryCategory!['id'] as String;
    final catName = vm.selectedDiscoveryCategory!['name'] as String;
    final results = vm.categoryResults[catId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'TOP ${catName.toUpperCase()}'),
        Expanded(
          child: _buildDiscoveryResultList(results, vm, settingsVM, theme),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color onSurface) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('No results found.', style: TextStyle(color: onSurface.withValues(alpha: 0.38))),
        ],
      ),
    );
  }

  Widget _buildDiscoveryResultList(List<PodcastSearchResult> results, PodcastViewModel vm, settings.SettingsViewModel settingsVM, ThemeData theme) {
    if (results.isEmpty && !vm.isLoading) return _buildEmptyState(theme.colorScheme.onSurface);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();

        if (settingsVM.libraryViewType == settings.LibraryViewType.list) {
          return ListView.separated(
            controller: _detailScrollController,
            itemCount: results.length + (vm.isLoading ? 1 : 0),
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              if (index == results.length) return const Center(child: CircularProgressIndicator());
              final item = results[index];
              return ListTile(
                leading: _buildMiniArt(item.imageUrl),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(item.artist, style: const TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.add_circle_outline, size: 18),
                onTap: () => vm.setActiveDiscoveryDetail({
                  'iTunesId': item.itunesId ?? item.feedUrl,
                  'title': item.title,
                  'artist': item.artist,
                  'imageUrl': item.imageUrl,
                  'feedUrl': item.feedUrl,
                }),
              );
            },
          );
        }

        return GridView.builder(
          controller: _detailScrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            childAspectRatio: 0.85,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: results.length + (vm.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == results.length) return const Center(child: CircularProgressIndicator());
            final item = results[index];
            return _buildDiscoveryGridItem(item, theme, vm);
          },
        );
      }
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
        child: url != null ? Image.network(
          url, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.podcasts, size: 20, color: Colors.white24),
        ) : const Icon(Icons.podcasts, size: 20, color: Colors.white24),
      ),
    );
  }

  Widget _buildDiscoveryGridItem(PodcastSearchResult result, ThemeData theme, PodcastViewModel vm) {
     return InkWell(
      onTap: () {
        vm.setActiveDiscoveryDetail({
          'iTunesId': result.itunesId ?? result.feedUrl,
          'title': result.title,
          'artist': result.artist,
          'imageUrl': result.imageUrl,
          'feedUrl': result.feedUrl,
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'pod_${result.itunesId ?? result.feedUrl}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    result.imageUrl != null 
                      ? Image.network(
                          result.imageUrl!, 
                          fit: BoxFit.cover, 
                          errorBuilder: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.podcasts)),
                        )
                      : Container(color: Colors.white10),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(result.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(result.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
        ],
      ),
    );
  }

  Widget _buildSearchResults(PodcastViewModel vm, ThemeData theme) {
    if (vm.isLoading && vm.searchResults.isEmpty) return const Center(child: CircularProgressIndicator());
    
    return ListView.builder(
      controller: _detailScrollController,
      itemCount: vm.searchResults.length + (vm.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == vm.searchResults.length) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        final result = vm.searchResults[index];
        return ListTile(
          leading: Hero(
            tag: 'pod_${result.itunesId ?? result.feedUrl}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: result.imageUrl != null 
                ? Image.network(result.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                : Container(width: 50, height: 50, color: Colors.white10),
            ),
          ),
          title: Text(result.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(result.artist, style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.add_circle_outline, size: 20),
          onTap: () {
            vm.setActiveDiscoveryDetail({
              'iTunesId': result.itunesId ?? result.feedUrl,
              'title': result.title,
              'artist': result.artist,
              'imageUrl': result.imageUrl,
              'feedUrl': result.feedUrl,
            });
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ExpandableSearch extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool expanded;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _ExpandableSearch({
    required this.controller,
    required this.focusNode,
    required this.expanded,
    required this.onToggle,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expanded ? 200 : 40,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.search, size: 18, color: expanded ? theme.colorScheme.primary : null),
            onPressed: () {
              onToggle(!expanded);
              if (expanded) {
                onClear();
              } else {
                focusNode.requestFocus();
              }
            },
          ),
          if (expanded)
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                onSubmitted: onSubmitted,
              ),
            ),
        ],
      ),
    );
  }
}
