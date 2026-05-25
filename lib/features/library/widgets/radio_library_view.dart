import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:provider/provider.dart';

class RadioLibraryView extends StatefulWidget {
  final VoidCallback? onExplore;
  const RadioLibraryView({super.key, this.onExplore});

  @override
  State<RadioLibraryView> createState() => _RadioLibraryViewState();
}

class _RadioLibraryViewState extends State<RadioLibraryView> with AutomaticKeepAliveClientMixin {
  final ScrollController _tabScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchExpanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _tabScrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final radioVM = context.watch<RadioViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      children: [
        // SUB-BAR: CATEGORIES & SEARCH
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
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
                          _buildFilterPill('ALL STATIONS', radioVM.libraryFilter == 'ALL STATIONS', theme, () => radioVM.setLibraryFilter('ALL STATIONS')),
                          const SizedBox(width: 8),
                          _buildFilterPill('RECENT', radioVM.libraryFilter == 'RECENT', theme, () => radioVM.setLibraryFilter('RECENT')),
                          const SizedBox(width: 8),
                          _buildFilterPill('AVAILABLE', radioVM.libraryFilter == 'AVAILABLE', theme, () => radioVM.setLibraryFilter('AVAILABLE')),
                        ],
                      ),
                    ),
                  ),
                ),
                _ExpandableSearch(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  expanded: _searchExpanded,
                  onToggle: (val) => setState(() => _searchExpanded = val),
                  onClear: () {
                    setState(() {
                      _searchExpanded = false;
                      _searchController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Row(
            children: [
              Text(
                'FAVORITE STATIONS',
                style: TextStyle(
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: radioVM.toggleShowingHidden,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                icon: Icon(radioVM.isShowingHidden ? Icons.visibility : Icons.visibility_off, size: 14),
                label: Text(
                  radioVM.isShowingHidden ? 'HIDE HIDDEN' : 'SHOW HIDDEN',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: radioVM.filteredFavorites.isEmpty && !radioVM.isShowingHidden
            ? _buildEmptyState(context, onSurface, radioVM)
            : _buildMainContent(radioVM, playerVM, settingsVM, theme, onSurface),
        ),
      ],
    );
  }

  Widget _buildMainContent(RadioViewModel radioVM, PlayerViewModel playerVM, settings.SettingsViewModel settingsVM, ThemeData theme, Color onSurface) {
    final list = radioVM.filteredFavorites;
    final String query = _searchController.text.toLowerCase();
    final filteredList = query.isEmpty 
        ? list 
        : list.where((s) => s.name.toLowerCase().contains(query)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();

        if (settingsVM.libraryViewType == settings.LibraryViewType.list) {
          return ListView.separated(
            key: const PageStorageKey('radio_library_list'),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            itemCount: filteredList.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: onSurface.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final station = filteredList[index];
              return _buildStationTile(station, theme, radioVM, playerVM, onSurface);
            },
          );
        }

        return GridView.builder(
          key: const PageStorageKey('radio_library_grid'),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            childAspectRatio: 0.85,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final station = filteredList[index];
            return _buildStationGridTile(station, theme, radioVM, playerVM, onSurface);
          },
        );
      }
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
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildStationTile(RadioStation station, ThemeData theme, RadioViewModel vm, PlayerViewModel playerVM, Color onSurface) {
    final bool isAvailable = station.isAvailable;
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildFavicon(station, theme),
        title: Row(
          children: [
            Expanded(
              child: Text(
                station.name, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  color: station.isHidden ? onSurface.withValues(alpha: 0.38) : null,
                  decoration: isAvailable ? null : TextDecoration.lineThrough,
                )
              ),
            ),
            if (station.isPinned)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.push_pin, size: 12, color: theme.colorScheme.primary),
              ),
          ],
        ),
        subtitle: Text(
          '${station.country ?? "Global"} • ${station.bitrate}kbps ${station.codec ?? ""}',
          style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.38)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                station.isPinned ? Icons.favorite : Icons.favorite_border,
                color: station.isPinned ? Colors.pinkAccent : onSurface.withValues(alpha: 0.24),
                size: 20,
              ),
              onPressed: () => vm.togglePin(station),
              tooltip: station.isPinned ? 'Unpin' : 'Pin to Top',
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: onSurface.withValues(alpha: 0.24), size: 20),
              onSelected: (val) {
                if (val == 'hide') vm.toggleHidden(station);
                if (val == 'remove') vm.toggleFavorite(station);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'hide',
                  child: Row(
                    children: [
                      Icon(station.isHidden ? Icons.visibility : Icons.visibility_off, size: 18),
                      const SizedBox(width: 12),
                      Text(station.isHidden ? 'Show Station' : 'Hide Station'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Text('Remove from Library', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => vm.playStation(station, playerVM, isAvailable: isAvailable),
      ),
    );
  }

  Widget _buildStationGridTile(RadioStation station, ThemeData theme, RadioViewModel vm, PlayerViewModel playerVM, Color onSurface) {
    final bool isAvailable = station.isAvailable;

    return GestureDetector(
      onTap: () => vm.playStation(station, playerVM, isAvailable: isAvailable),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildFavicon(station, theme, large: true),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: Icon(
                        station.isFavorite ? Icons.library_add_check : Icons.library_add, 
                        color: Colors.white, 
                        size: 16,
                      ),
                    ),
                  ),
                  if (station.isPinned)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.8), shape: BoxShape.circle),
                        child: const Icon(Icons.push_pin, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              station.name, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                color: station.isHidden ? onSurface.withValues(alpha: 0.38) : null,
                decoration: isAvailable ? null : TextDecoration.lineThrough,
              )
            ),
            Text(
              '${station.country ?? "Global"} • ${station.bitrate}k', 
              style: TextStyle(fontSize: 9, color: onSurface.withValues(alpha: 0.38)),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color onSurface, RadioViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radio, size: 64, color: onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'No saved radio stations.',
            style: TextStyle(color: onSurface.withValues(alpha: 0.38)),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: vm.toggleShowingHidden,
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('SHOW HIDDEN STATIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFavicon(RadioStation station, ThemeData theme, {bool large = false}) {
    final url = station.favicon;
    return Stack(
      children: [
        Container(
          width: large ? double.infinity : 44,
          height: large ? double.infinity : 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: url != null && url.isNotEmpty
                ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.radio, size: large ? 48 : 20))
                : Icon(Icons.radio, size: large ? 48 : 20),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: large ? 12 : 10,
            height: large ? 12 : 10,
            decoration: BoxDecoration(
              color: station.isAvailable ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableSearch extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool expanded;
  final ValueChanged<bool> onToggle;
  final VoidCallback onClear;

  const _ExpandableSearch({
    required this.controller,
    required this.focusNode,
    required this.expanded,
    required this.onToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expanded ? 200 : 40,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.search, size: 18, color: expanded ? theme.colorScheme.primary : null),
            onPressed: () {
              onToggle(!expanded);
              if (expanded) {
                onClear();
              } else {
                focusNode.requestFocus();
              }
            },
          ),
          if (expanded)
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search library...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (val) {
                   // Local filtering is handled by re-building the list
                   (context as Element).markNeedsBuild();
                },
              ),
            ),
        ],
      ),
    );
  }
}
