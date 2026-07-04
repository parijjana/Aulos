import 'package:flutter/material.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:provider/provider.dart';
import 'librivox_shelf_view.dart';
import 'librivox_book_item.dart';

class LibriVoxStorefrontBody extends StatelessWidget {
  final LibriVoxViewModel vm;
  final LibraryViewModel libraryVM;
  final Map<String, dynamic>? selectedCategory;
  final bool isSearching;
  final List<Map<String, dynamic>> categories;
  final void Function(Map<String, dynamic>)? onCategorySelected;

  const LibriVoxStorefrontBody({
    super.key,
    required this.vm,
    required this.libraryVM,
    required this.selectedCategory,
    required this.isSearching,
    required this.categories,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsVM = context.watch<settings.SettingsViewModel>();

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
      return _buildResults(context, results, 'Search Results for "${vm.lastSearchQuery}"', settingsVM);
    }

    if (selectedCategory != null) {
      final results = vm.filteredResults;
      if (vm.isLoading && results.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildResults(context, results, 'Top ${selectedCategory!['name']} Books', settingsVM);
    }

    // Main storefront view with multiple shelves
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Featured classics
        LibriVoxShelfView(
          title: 'Featured Classics',
          books: vm.categoryResults[''] ?? vm.searchResults,
          onSeeAll: onCategorySelected != null
              ? () => onCategorySelected!(categories.first)
              : null,
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
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
                  onSeeAll: onCategorySelected != null
                      ? () => onCategorySelected!(cat)
                      : null,
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildResults(BuildContext context, List<LibriVoxBook> books, String title, settings.SettingsViewModel settingsVM) {
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
          child: settingsVM.libraryViewType == settings.LibraryViewType.list
              ? _buildListView(context, books)
              : _buildGridView(context, books),
        ),
      ],
    );
  }

  Widget _buildListView(BuildContext context, List<LibriVoxBook> books) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: books.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        final bool isDownloaded = libraryVM.books.any((b) => b.librivoxId == book.id && b.isDownloadedViaAulos);
        
        return ListTile(
          leading: _buildMiniCover(book),
          title: Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          subtitle: Text(
            book.authorNames,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
          trailing: Icon(
            isDownloaded ? Icons.download_done_rounded : Icons.download_outlined,
            size: 18,
            color: isDownloaded ? Colors.teal : null,
          ),
          onTap: () {
            vm.selectBook(book);
            final isWide = MediaQuery.of(context).size.width >= 720;
            if (!isWide) {
              DefaultTabController.maybeOf(context)?.animateTo(1);
            }
          },
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<LibriVoxBook> books) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.5,
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
    );
  }

  Widget _buildMiniCover(LibriVoxBook book) {
    final hash = book.title.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    final startColor = HSLColor.fromAHSL(1.0, hue, 0.65, 0.22).toColor();
    final endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.75, 0.12).toColor();
    final String firstLetter = book.title.isNotEmpty ? book.title[0].toUpperCase() : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
        ),
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
            ),
          ),
        ),
      ),
    );
  }
}
