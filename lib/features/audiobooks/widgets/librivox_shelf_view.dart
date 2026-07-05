import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'librivox_book_item.dart';

class LibriVoxShelfView extends StatelessWidget {
  final List<LibriVoxBook> books;
  final String title;
  final VoidCallback? onSeeAll;

  const LibriVoxShelfView({
    super.key,
    required this.title,
    required this.books,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<LibriVoxViewModel>();
    final libraryVM = context.watch<LibraryViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              if (onSeeAll != null && books.isNotEmpty)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('SEE ALL', style: TextStyle(fontSize: 10)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: LibriVoxBookItem(
                  book: book,
                  libraryVM: libraryVM,
                  vm: vm,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
