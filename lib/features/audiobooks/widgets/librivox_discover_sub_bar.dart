import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/features/podcasts/widgets/expandable_search.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';

class LibriVoxDiscoverSubBar extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Map<String, dynamic>? selectedCategory;
  final ScrollController categoryScrollController;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final bool isSearching;
  final bool searchExpanded;
  final Function(Map<String, dynamic>) onCategorySelected;
  final Function(String) onSearchSubmitted;
  final VoidCallback onClear;
  final Function(bool) onSearchExpandedChanged;
  final ValueChanged<String>? onChanged;

  const LibriVoxDiscoverSubBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.categoryScrollController,
    required this.searchController,
    required this.searchFocus,
    required this.isSearching,
    required this.searchExpanded,
    required this.onCategorySelected,
    required this.onSearchSubmitted,
    required this.onClear,
    required this.onSearchExpandedChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
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
                      if (selectedCategory != null || isSearching)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 14),
                          onPressed: onClear,
                          tooltip: 'Back to Storefront',
                        ),
                      ...categories.map((cat) {
                        final isActive = selectedCategory == cat && !isSearching;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => onCategorySelected(cat),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                cat['name'].toString().toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ExpandableSearch(
              controller: searchController,
              focusNode: searchFocus,
              expanded: searchExpanded,
              onToggle: onSearchExpandedChanged,
              onSubmitted: onSearchSubmitted,
              onClear: onClear,
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () {
                context.read<LibriVoxViewModel>().loadCategoryPreviews(categories, force: true);
              },
              tooltip: 'Refresh Discovery',
            ),
          ],
        ),
      ),
    );
  }
}
