import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;

class LibraryHeader extends StatefulWidget {
  final LibraryViewModel viewModel;
  final TabController subTabController;
  final ScrollController scrollController;

  const LibraryHeader({
    super.key,
    required this.viewModel,
    required this.subTabController,
    required this.scrollController,
  });

  @override
  State<LibraryHeader> createState() => _LibraryHeaderState();
}

class _LibraryHeaderState extends State<LibraryHeader> {
  final ScrollController _tabScrollController = ScrollController();

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildTopBar(context, theme),
        const SizedBox(height: 8),
        _buildSubBar(context, theme),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, ThemeData theme) {
    final settingsVM = widget.viewModel.settingsVM;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 1. Back Button or Breadcrumb
          if (!widget.viewModel.isAtRoot)
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary, size: 16),
              onPressed: widget.viewModel.goBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          
          // Primary Nav (Always LIBRARY in music)
          _buildNavButton('YOUR LIBRARY', true, theme),
          
          const Spacer(),
          
          if (settingsVM != null) _ViewModeSelector(settingsVM: settingsVM),
          
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary, size: 20),
            onPressed: widget.viewModel.autoDiscover,
            tooltip: 'Auto-Discover',
          ),
        ],
      ),
    );
  }

  Widget _buildSubBar(BuildContext context, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            // 1. Scrollable Categories
            Expanded(
              child: Scrollbar(
                controller: _tabScrollController,
                thumbVisibility: true,
                thickness: 2,
                radius: const Radius.circular(2),
                child: SingleChildScrollView(
                  controller: _tabScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      if (!widget.viewModel.isAtRoot) ...[
                        const Icon(Icons.chevron_right, size: 14, color: Colors.white24),
                        const SizedBox(width: 8),
                        Text(
                          _getTitle(widget.viewModel).toUpperCase(),
                          style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2),
                        ),
                        const SizedBox(width: 24),
                      ] else ...[
                        TabBar(
                          controller: widget.subTabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: Colors.transparent,
                          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          tabs: const [
                            Tab(text: 'FOLDERS'),
                            Tab(text: 'ARTISTS'),
                            Tab(text: 'ALBUMS'),
                            Tab(text: 'GENRES'),
                            Tab(text: 'YEARS'),
                            Tab(text: 'PLAYLISTS'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // 2. Expandable Search
            _ExpandableSearch(viewModel: widget.viewModel),
            
            if (!widget.viewModel.isAtRoot)
              TextButton.icon(
                onPressed: () => widget.viewModel.setMode(widget.viewModel.mode), // Reset to root
                icon: const Icon(Icons.library_music_outlined, size: 16),
                label: const Text('LIBRARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, bool isActive, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  String _getTitle(LibraryViewModel vm) {
    final item = vm.selectedItem;
    if (item == null) return '';
    if (item is String) return item;
    if (item is LibraryMode) return item.name;
    try {
      return (item as dynamic).name ?? (item as dynamic).title ?? 'Detail';
    } catch (_) {
      return 'Detail';
    }
  }
}

class _ExpandableSearch extends StatefulWidget {
  final LibraryViewModel viewModel;
  const _ExpandableSearch({required this.viewModel});

  @override
  State<_ExpandableSearch> createState() => _ExpandableSearchState();
}

class _ExpandableSearchState extends State<_ExpandableSearch> {
  bool _expanded = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _expanded ? 200 : 40,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.search, size: 18, color: _expanded ? theme.colorScheme.primary : null),
            onPressed: () {
              setState(() => _expanded = !_expanded);
              if (!_expanded) {
                _controller.clear();
                widget.viewModel.setSearchQuery('');
              } else {
                _focusNode.requestFocus();
              }
            },
          ),
          if (_expanded)
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search library...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (val) => widget.viewModel.setSearchQuery(val),
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewModeSelector extends StatelessWidget {
  final settings.SettingsViewModel settingsVM;
  const _ViewModeSelector({required this.settingsVM});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return PopupMenuButton<settings.LibraryViewType>(
      initialValue: settingsVM.libraryViewType,
      onSelected: settingsVM.setLibraryViewType,
      icon: Icon(Icons.grid_view_rounded, color: primary.withValues(alpha: 0.7), size: 20),
      tooltip: 'View Mode',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: settings.LibraryViewType.list,
          child: Row(
            children: [
              Icon(Icons.list, size: 18, color: settingsVM.libraryViewType == settings.LibraryViewType.list ? primary : onSurface),
              const SizedBox(width: 12),
              const Text('List View', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: settings.LibraryViewType.grid,
          child: Row(
            children: [
              Icon(Icons.grid_view, size: 18, color: settingsVM.libraryViewType == settings.LibraryViewType.grid ? primary : onSurface),
              const SizedBox(width: 12),
              const Text('Grid View', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: settings.LibraryViewType.orbit,
          child: Row(
            children: [
              Icon(Icons.blur_circular, size: 18, color: settingsVM.libraryViewType == settings.LibraryViewType.orbit ? primary : onSurface),
              const SizedBox(width: 12),
              const Text('Orbit View', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
