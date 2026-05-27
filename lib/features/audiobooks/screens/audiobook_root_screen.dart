import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/features/audiobooks/widgets/audiobook_library_view.dart';
import 'package:aulos/features/audiobooks/widgets/audiobook_bookmarks_sidebar.dart';
import 'package:provider/provider.dart';

class AudiobookRootScreen extends StatefulWidget {
  const AudiobookRootScreen({super.key});

  @override
  State<AudiobookRootScreen> createState() => _AudiobookRootScreenState();
}

class _AudiobookRootScreenState extends State<AudiobookRootScreen> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _activeTab = 0;
  bool _isSearchExpanded = false;
  bool _isSidebarOpen = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _activeTab = index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final libraryVM = context.watch<LibraryViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              _buildUnifiedHeader(libraryVM),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _activeTab = index),
                  children: [
                    const AudiobookLibraryView(),
                    _buildDiscoverPlaceholder(theme),
                  ],
                ),
              ),
            ],
          ),
          
          // SIDEBAR (Global Clips)
          if (_activeTab == 0 && libraryVM.isAtRoot) ...[
            _buildSidebarPullTab(theme),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _isSidebarOpen ? 0 : -350,
              top: 0,
              bottom: 0,
              child: const AudiobookBookmarksSidebar(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarPullTab(ThemeData theme) {
    return Positioned(
      right: _isSidebarOpen ? 350 : 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: GestureDetector(
          onTap: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
          child: Container(
            width: 24,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Icon(
              _isSidebarOpen ? Icons.chevron_right_rounded : Icons.bookmark_outline_rounded, 
              size: 16, 
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedHeader(LibraryViewModel vm) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!_isSearchExpanded) ...[
            _buildNavButton('LIBRARY', 0, _activeTab == 0, theme),
            const SizedBox(width: 8),
            _buildNavButton('DISCOVER', 1, _activeTab == 1, theme),
          ],
          const Spacer(),
          _buildSearchArea(vm, theme),
        ],
      ),
    );
  }

  Widget _buildSearchArea(LibraryViewModel vm, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSearchExpanded ? 240 : 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isSearchExpanded ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
              size: 18,
              color: _isSearchExpanded ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                  vm.setSearchQuery('');
                }
              });
            },
            visualDensity: VisualDensity.compact,
          ),
          if (_isSearchExpanded)
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: vm.setSearchQuery,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Search books...',
                  hintStyle: TextStyle(fontSize: 11),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(right: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, int index, bool isActive, ThemeData theme) {
    return InkWell(
      onTap: () => _navigateToPage(index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isActive ? null : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.public_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Text(
            'LibriVox & Internet Archive Integration Coming Soon',
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.24), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
