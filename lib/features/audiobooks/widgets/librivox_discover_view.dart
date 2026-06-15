import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/features/audiobooks/widgets/librivox_book_detail_view.dart';
import 'package:aulos/features/audiobooks/widgets/librivox_discover_sub_bar.dart';
import 'package:aulos/features/audiobooks/widgets/librivox_storefront_body.dart';

class LibriVoxDiscoverView extends StatefulWidget {
  const LibriVoxDiscoverView({super.key});

  @override
  State<LibriVoxDiscoverView> createState() => _LibriVoxDiscoverViewState();
}

class _LibriVoxDiscoverViewState extends State<LibriVoxDiscoverView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _categoryScrollController = ScrollController();
  bool _searchExpanded = false;
  bool _isSearching = false;
  Map<String, dynamic>? _selectedCategory;

  final List<Map<String, dynamic>> _librivoxCategories = const [
    {'name': 'Featured', 'query': ''},
    {'name': 'Fiction', 'query': 'fiction'},
    {'name': 'Poetry', 'query': 'poetry'},
    {'name': 'Drama', 'query': 'drama'},
    {'name': 'History', 'query': 'history'},
    {'name': 'Sci-Fi', 'query': 'science fiction'},
    {'name': 'Biography', 'query': 'biography'},
    {'name': 'Children', 'query': 'children'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<LibriVoxViewModel>();
      vm.loadCategoryPreviews(_librivoxCategories);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final vm = context.watch<LibriVoxViewModel>();
    final libraryVM = context.watch<LibraryViewModel>();

    final isWide = MediaQuery.of(context).size.width >= 720;

    final storefront = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibriVoxDiscoverSubBar(
          categories: _librivoxCategories,
          selectedCategory: _selectedCategory,
          categoryScrollController: _categoryScrollController,
          searchController: _searchController,
          searchFocus: _searchFocus,
          isSearching: _isSearching,
          searchExpanded: _searchExpanded,
          onCategorySelected: (cat) {
            setState(() {
              _selectedCategory = cat;
              _isSearching = false;
              _searchExpanded = false;
              _searchController.clear();
            });
            vm.search(cat['query']);
          },
          onSearchSubmitted: (val) {
            if (val.isNotEmpty) {
              setState(() {
                _isSearching = true;
                _selectedCategory = null;
              });
              vm.search(val);
            }
          },
          onClear: () {
            setState(() {
              _isSearching = false;
              _searchExpanded = false;
              _selectedCategory = null;
              _searchController.clear();
            });
            vm.loadCategoryPreviews(_librivoxCategories);
          },
          onSearchExpandedChanged: (val) {
            setState(() => _searchExpanded = val);
          },
          onChanged: vm.setFilterQuery,
        ),
        if (vm.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Error: ${vm.error}',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => vm.loadCategoryPreviews(_librivoxCategories, force: true),
            child: LibriVoxStorefrontBody(
              vm: vm,
              libraryVM: libraryVM,
              selectedCategory: _selectedCategory,
              isSearching: _isSearching,
              categories: _librivoxCategories,
            ),
          ),
        ),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          // Sync navigation index based on selectedBook
          if (vm.selectedBook != null && !isWide) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller = DefaultTabController.maybeOf(context);
              if (controller != null && controller.index == 0) {
                controller.index = 1;
              }
            });
          } else if (vm.selectedBook == null && !isWide) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller = DefaultTabController.maybeOf(context);
              if (controller != null && controller.index == 1) {
                controller.index = 0;
              }
            });
          }

          final detailPane = vm.selectedBook != null
              ? LibriVoxBookDetailView(
                  book: vm.selectedBook!,
                  onBack: isWide
                      ? null
                      : () {
                          vm.selectBook(null);
                          if (!isWide) {
                            DefaultTabController.maybeOf(context)?.animateTo(0);
                          }
                        },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a book to view details',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                );

          if (isWide) {
            return Container(
              decoration: _buildBackgroundGradient(theme),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      child: storefront,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      child: detailPane,
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: _buildBackgroundGradient(theme),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                storefront,
                vm.selectedBook != null
                    ? LibriVoxBookDetailView(
                        book: vm.selectedBook!,
                        onBack: () {
                          vm.selectBook(null);
                          DefaultTabController.maybeOf(context)?.animateTo(0);
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surface.withOpacity(0.95),
          theme.colorScheme.surface.withOpacity(0.85),
        ],
      ),
    );
  }
}
