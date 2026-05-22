import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/data/database/discovery_database.dart';
import 'package:aulos/features/podcasts/screens/podcast_detail_screen.dart';
import 'package:provider/provider.dart';

class PodcastBrowserScreen extends StatefulWidget {
  const PodcastBrowserScreen({super.key});

  @override
  State<PodcastBrowserScreen> createState() => _PodcastBrowserScreenState();
}

class _PodcastBrowserScreenState extends State<PodcastBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _detailScrollController = ScrollController();
  bool _isSearching = false;

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
    _detailScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastVM = context.watch<PodcastViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (podcastVM.activeDiscoveryDetail == null)
              _buildSearchHeader(podcastVM, theme),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBody(podcastVM, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(PodcastViewModel vm, ThemeData theme) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _isSearching = false);
                  _searchController.clear();
                },
              ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search 1,000,000+ podcasts...',
                  border: InputBorder.none,
                  prefixIcon: _isSearching ? null : const Icon(Icons.search, size: 20),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                onChanged: (val) {
                  if (!_isSearching && val.isNotEmpty) {
                    setState(() => _isSearching = true);
                  }
                },
                onSubmitted: (val) => vm.search(val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PodcastViewModel vm, ThemeData theme) {
    if (vm.activeDiscoveryDetail != null) {
      return const PodcastDetailScreen();
    }

    if (vm.selectedDiscoveryCategory != null) {
      return _buildCategoryDetailView(vm, theme);
    }

    if (_isSearching) {
      return _buildSearchResults(vm, theme);
    }

    return RefreshIndicator(
      onRefresh: vm.refreshDiscovery,
      child: ListView(
        children: [
          _buildSectionHeader(theme, 'BROWSE BY CATEGORY'),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _discoveryCategories.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryChip(_discoveryCategories[index], theme),
              ),
            ),
          ),
          const SizedBox(height: 24),
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
          height: 180,
          child: results.isEmpty 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildDiscoveryItem(item, theme, vm),
                  );
                },
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryChip(Map<String, dynamic> cat, ThemeData theme) {
    return InkWell(
      onTap: () => _onCategorySelected(cat),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icon'] as IconData, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(cat['name'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
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
          height: 180,
          child: results.isEmpty 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildDiscoveryItem(item, theme, vm),
                  );
                },
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryDetailView(PodcastViewModel vm, ThemeData theme) {
    final catId = vm.selectedDiscoveryCategory!['id'] as String;
    final catName = vm.selectedDiscoveryCategory!['name'] as String;
    final results = vm.categoryResults[catId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => vm.setSelectedDiscoveryCategory(null),
            ),
            const SizedBox(width: 8),
            _buildSectionHeader(theme, 'TOP ${catName.toUpperCase()}'),
          ],
        ),
        Expanded(
          child: GridView.builder(
            controller: _detailScrollController,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: results.length + (vm.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == results.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final item = results[index];
              return _buildDiscoveryItem(item, theme, vm, isHorizontal: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryItem(PodcastSearchResult result, ThemeData theme, PodcastViewModel vm, {bool isHorizontal = true}) {
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
      child: SizedBox(
        width: isHorizontal ? 140 : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'pod_${result.itunesId ?? result.feedUrl}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      result.imageUrl != null 
                        ? Image.network(
                            result.imageUrl!, 
                            fit: BoxFit.cover, 
                            width: double.infinity,
                            height: double.infinity,
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
            const SizedBox(height: 8),
            Text(result.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            Text(result.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
          ],
        ),
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
