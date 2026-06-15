import 'package:flutter/material.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'librivox_shelf_view.dart';
import 'librivox_book_item.dart';

class LibriVoxStorefrontBody extends StatelessWidget {
  final LibriVoxViewModel vm;
  final LibraryViewModel libraryVM;
  final Map<String, dynamic>? selectedCategory;
  final bool isSearching;
  final List<Map<String, dynamic>> categories;

  const LibriVoxStorefrontBody({
    super.key,
    required this.vm,
    required this.libraryVM,
    required this.selectedCategory,
    required this.isSearching,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (vm.isLoading && selectedCategory == null && !isSearching && vm.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final allCategoriesEmpty = vm.categoryResults.isEmpty || vm.categoryResults.values.every((list) => list.isEmpty);
    if (!vm.isLoading && allCategoriesEmpty && vm.searchResults.isEmpty && !isSearching && selectedCategory == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_rounded,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'No audiobooks found.',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (isSearching) {
      final results = vm.filteredResults;
      if (vm.isLoading && results.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildGrid(context, results, 'Search Results for "${vm.lastSearchQuery}"');
    }

    if (selectedCategory != null) {
      final results = vm.filteredResults;
      if (vm.isLoading && results.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildGrid(context, results, 'Top ${selectedCategory!['name']} Books');
    }

    // Main storefront view with multiple shelves
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Featured classics
        LibriVoxShelfView(
          title: 'Featured Classics',
          books: vm.categoryResults[''] ?? vm.searchResults,
        ),
        
        // Other genres loaded asynchronously
        ...categories.skip(1).map((cat) {
          final query = cat['query'] as String;
          final books = vm.categoryResults[query] ?? [];
          final isLoading = vm.categoryLoading[query] ?? false;

          if (books.isEmpty && !isLoading) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              if (isLoading && books.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top ${cat['name']} Books'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                )
              else
                LibriVoxShelfView(
                  title: 'Top ${cat['name']} Books',
                  books: books,
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<LibriVoxBook> books, String title) {
    final theme = Theme.of(context);
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_rounded,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'No audiobooks found.',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              childAspectRatio: 0.55,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return LibriVoxBookItem(
                book: book,
                libraryVM: libraryVM,
                vm: vm,
              );
            },
          ),
        ),
      ],
    );
  }
}
