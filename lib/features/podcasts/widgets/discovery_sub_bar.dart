import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/features/podcasts/widgets/expandable_search.dart';

class DiscoverySubBar extends StatelessWidget {
  final PodcastViewModel vm;
  final List<Map<String, dynamic>> discoveryCategories;
  final ScrollController categoryScrollController;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final bool isSearching;
  final bool searchExpanded;
  final void Function(Map<String, dynamic>) onCategorySelected;
  final void Function({required bool isSearching, required bool searchExpanded}) onSearchStateChanged;

  const DiscoverySubBar({
    super.key,
    required this.vm,
    required this.discoveryCategories,
    required this.categoryScrollController,
    required this.searchController,
    required this.searchFocus,
    required this.isSearching,
    required this.searchExpanded,
    required this.onCategorySelected,
    required this.onSearchStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            // 1. SCROLLABLE CATEGORIES
            Expanded(
              child: Scrollbar(
                controller: categoryScrollController,
                thumbVisibility: true,
                thickness: 2,
                radius: const Radius.circular(2),
                child: SingleChildScrollView(
                  controller: categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      if (vm.selectedDiscoveryCategory != null || isSearching)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 14),
                          onPressed: () {
                            vm.setSelectedDiscoveryCategory(null);
                            onSearchStateChanged(isSearching: false, searchExpanded: false);
                            searchController.clear();
                          },
                        ),
                      ...discoveryCategories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterPill(
                          cat['name']?.toString() ?? 'Category',
                          vm.selectedDiscoveryCategory?['id'] == cat['id'],
                          theme,
                          () => onCategorySelected(cat),
                        ),
                      )).toList(),
                      const SizedBox(width: 24), // Buffer
                    ],
                  ),
                ),
              ),
            ),

            // 2. EXPANDABLE SEARCH
            ExpandableSearch(
              controller: searchController,
              focusNode: searchFocus,
              expanded: searchExpanded,
              onToggle: (val) => onSearchStateChanged(isSearching: isSearching, searchExpanded: val),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  onSearchStateChanged(isSearching: true, searchExpanded: searchExpanded);
                  vm.search(val);
                }
              },
              onClear: () {
                onSearchStateChanged(isSearching: false, searchExpanded: false);
                searchController.clear();
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () => vm.refreshDiscovery(),
              tooltip: 'Refresh Discovery',
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
}
