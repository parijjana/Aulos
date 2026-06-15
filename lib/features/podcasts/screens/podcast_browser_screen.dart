import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/features/podcasts/screens/podcast_detail_screen.dart';
import 'package:aulos/features/podcasts/widgets/discovery_category_shelf.dart';
import 'package:aulos/features/podcasts/widgets/discovery_trending_shelf.dart';
import 'package:aulos/features/podcasts/widgets/discovery_search_results.dart';
import 'package:aulos/features/podcasts/widgets/discovery_result_list.dart';
import 'package:aulos/features/podcasts/widgets/discovery_sub_bar.dart';
import 'package:provider/provider.dart';

class PodcastBrowserScreen extends StatefulWidget {
  const PodcastBrowserScreen({super.key});

  @override
  State<PodcastBrowserScreen> createState() => _PodcastBrowserScreenState();
}

class _PodcastBrowserScreenState extends State<PodcastBrowserScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
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
        final catId = selectedCategory['id']?.toString() ?? '';
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

  void _onCategorySelected(Map<String, dynamic> cat) {
    context.read<PodcastViewModel>().setSelectedDiscoveryCategory(cat);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final podcastVM = context.watch<PodcastViewModel>();
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (podcastVM.activeDiscoveryDetail == null)
            DiscoverySubBar(
              vm: podcastVM,
              discoveryCategories: _discoveryCategories,
              categoryScrollController: _categoryScrollController,
              searchController: _searchController,
              searchFocus: _searchFocus,
              isSearching: _isSearching,
              searchExpanded: _searchExpanded,
              onCategorySelected: _onCategorySelected,
              onSearchStateChanged: ({required bool isSearching, required bool searchExpanded}) {
                setState(() {
                  _isSearching = isSearching;
                  _searchExpanded = searchExpanded;
                });
              },
            ),
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

  Widget _buildBody(PodcastViewModel vm, settings.SettingsViewModel settingsVM, ThemeData theme) {
    if (vm.activeDiscoveryDetail != null) {
      return const PodcastDetailScreen();
    }

    if (vm.selectedDiscoveryCategory != null) {
      return _buildCategoryDetailView(vm, settingsVM, theme);
    }

    if (_isSearching) {
      return DiscoverySearchResults(
        vm: vm,
        scrollController: _detailScrollController,
      );
    }

    return RefreshIndicator(
      onRefresh: vm.refreshDiscovery,
      child: ListView(
        children: [
          DiscoveryTrendingShelf(vm: vm),
          ..._discoveryCategories.map((cat) => DiscoveryCategoryShelf(
            cat: cat,
            vm: vm,
            onSeeAll: _onCategorySelected,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailView(PodcastViewModel vm, settings.SettingsViewModel settingsVM, ThemeData theme) {
    final selectedCategory = vm.selectedDiscoveryCategory;
    if (selectedCategory == null) return const SizedBox.shrink();
    final catId = selectedCategory['id']?.toString() ?? '';
    final catName = selectedCategory['name']?.toString() ?? 'Category';
    final results = vm.categoryResults[catId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'TOP ${catName.toUpperCase()}'),
        Expanded(
          child: DiscoveryResultList(
            results: results,
            vm: vm,
            settingsVM: settingsVM,
            scrollController: _detailScrollController,
          ),
        ),
      ],
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
