import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/features/library/widgets/library_grid_view.dart';
import 'package:aulos/features/library/widgets/library_sub_list.dart';
import 'package:provider/provider.dart';
import 'audiobook_detail_view.dart';

class AudiobookLibraryView extends StatefulWidget {
  const AudiobookLibraryView({super.key});

  @override
  State<AudiobookLibraryView> createState() => _AudiobookLibraryViewState();
}

class _AudiobookLibraryViewState extends State<AudiobookLibraryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryViewModel>().setMode(LibraryMode.books);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryVM = context.watch<LibraryViewModel>();
    final theme = Theme.of(context);

    if (libraryVM.isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    final bool isAtRoot = libraryVM.isAtRootFor(LibraryMode.books);
    final dynamic selectedItem = libraryVM.selectedItemFor(LibraryMode.books);

    if (isAtRoot && libraryVM.books.isEmpty) {
      return _buildEmptyState(theme, libraryVM);
    }

    if (selectedItem is Album) {
      return AudiobookDetailView(
        book: selectedItem,
        onBack: libraryVM.goBack,
      );
    }

    return Column(
      children: [
        if (isAtRoot) _buildSortBar(theme, libraryVM),
        Expanded(
          child: isAtRoot
              ? LibraryGridView(
                  viewModel: libraryVM,
                  scrollController: _scrollController,
                )
              : LibrarySubList(
                  viewModel: libraryVM,
                  scrollController: _scrollController,
                ),
        ),
      ],
    );
  }

  Widget _buildSortBar(ThemeData theme, LibraryViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          const Text('SORT BY:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white24)),
          const SizedBox(width: 12),
          _buildSortPill('NAME', AudiobookSort.name, theme, vm),
          const SizedBox(width: 8),
          _buildSortPill('AUTHOR', AudiobookSort.author, theme, vm),
          const SizedBox(width: 8),
          _buildSortPill('SERIES', AudiobookSort.series, theme, vm),
          const SizedBox(width: 8),
          _buildSortPill('PLAYED', AudiobookSort.played, theme, vm),
          const Spacer(),
          _buildAulosFilterPill(theme, vm),
        ],
      ),
    );
  }

  Widget _buildSortPill(String label, AudiobookSort sort, ThemeData theme, LibraryViewModel vm) {
    final bool isActive = vm.bookSort == sort;
    return InkWell(
      onTap: () => vm.setBookSort(sort),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildAulosFilterPill(ThemeData theme, LibraryViewModel vm) {
    final bool isActive = vm.bookFilterAulos;
    return InkWell(
      onTap: () => vm.setBookFilterAulos(!isActive),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? Colors.teal : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 10, color: isActive ? Colors.teal : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            Text(
              'AULOS',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.teal : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, LibraryViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          const Text('No audiobooks found.', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Add a folder containing your purchased audiobooks in Settings.',
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              vm.pickFolder(folderType: 1);
            },
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('ADD AUDIOBOOK FOLDER'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ],
      ),
    );
  }
}
