import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/data/database/radio_database.dart';
import 'package:provider/provider.dart';

class RadioBrowserScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RadioBrowserScreen({super.key, this.onBack});

  @override
  State<RadioBrowserScreen> createState() => _RadioBrowserScreenState();
}

enum _DiscoveryTab { genre, country, language }

class _RadioBrowserScreenState extends State<RadioBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  
  bool _isSearching = false;
  bool _searchExpanded = false;
  _DiscoveryTab _activeTab = _DiscoveryTab.genre;
  
  String? _selectedDetailTitle;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.hasClients && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final vm = context.read<RadioViewModel>();
      if (!vm.isLoading) {
        vm.checkMoreUnavailableHealth();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radioVM = context.watch<RadioViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildSubBar(radioVM, theme),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildBody(radioVM, playerVM, settingsVM, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubBar(RadioViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            // 1. SCROLLABLE CATEGORIES
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
                      if (_selectedDetailTitle != null || _isSearching)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 14),
                          onPressed: () => setState(() {
                            _selectedDetailTitle = null;
                            _isSearching = false;
                            _searchExpanded = false;
                            _searchController.clear();
                          }),
                        ),
                      _buildTabButton('GENRE', _DiscoveryTab.genre, theme),
                      const SizedBox(width: 8),
                      _buildTabButton('REGION', _DiscoveryTab.country, theme),
                      const SizedBox(width: 8),
                      _buildTabButton('LANG', _DiscoveryTab.language, theme),
                      const SizedBox(width: 24), // Buffer
                    ],
                  ),
                ),
              ),
            ),

            // 2. EXPANDABLE SEARCH
            _ExpandableSearch(
              controller: _searchController,
              focusNode: _searchFocus,
              expanded: _searchExpanded,
              onToggle: (val) => setState(() => _searchExpanded = val),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  setState(() => _isSearching = true);
                  vm.search(val);
                }
              },
              onClear: () {
                setState(() {
                  _isSearching = false;
                  _searchExpanded = false;
                  _searchController.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, _DiscoveryTab tab, ThemeData theme) {
    final isActive = _activeTab == tab && _selectedDetailTitle == null && !_isSearching;
    return InkWell(
      onTap: () => setState(() {
         _activeTab = tab;
         _selectedDetailTitle = null;
         _isSearching = false;
      }),
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
            letterSpacing: 1.0,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RadioViewModel vm, PlayerViewModel playerVM, settings.SettingsViewModel settingsVM, ThemeData theme) {
    if (vm.isLoading && vm.browseResults.isEmpty && vm.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isSearching) {
      return _buildStationList(vm.searchResults, theme, vm, settingsVM, 'SEARCH RESULTS');
    }

    if (_selectedDetailTitle != null) {
      return _buildStationList(vm.browseResults, theme, vm, settingsVM, _selectedDetailTitle!);
    }

    switch (_activeTab) {
      case _DiscoveryTab.genre:
        return _buildGrid(
          vm.categories.map((c) => c.name).toList(),
          theme,
          (val) {
            setState(() => _selectedDetailTitle = 'GENRE: ${val.toUpperCase()}');
            vm.browseCategory(val).then((_) => vm.checkHealthForBrowseResults());
          }
        );
      case _DiscoveryTab.country:
        return _buildGrid(
          vm.allCountries.map((c) => c['name'] as String).toList(),
          theme,
          (val) {
            setState(() => _selectedDetailTitle = 'COUNTRY: ${val.toUpperCase()}');
            vm.browseByCountry(val).then((_) => vm.checkHealthForBrowseResults());
          }
        );
      case _DiscoveryTab.language:
        return _buildGrid(
          vm.allLanguages.map((l) => l['name'] as String).toList(),
          theme,
          (val) {
            setState(() => _selectedDetailTitle = 'LANGUAGE: ${val.toUpperCase()}');
            vm.browseByLanguage(val).then((_) => vm.checkHealthForBrowseResults());
          }
        );
    }
  }

  Widget _buildGrid(List<String> items, ThemeData theme, ValueChanged<String> onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();
        
        return GridView.builder(
          key: PageStorageKey('radio_grid_${_activeTab.name}'),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: () => onTap(item),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                ),
                child: Text(
                  item.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildStationList(List<RadioStation> stations, ThemeData theme, RadioViewModel vm, settings.SettingsViewModel settingsVM, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.5)),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 0) return const SizedBox.shrink();

              if (settingsVM.libraryViewType == settings.LibraryViewType.list) {
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: stations.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  itemBuilder: (context, index) => _buildStationTile(stations[index], theme, vm),
                );
              }

              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: stations.length,
                itemBuilder: (context, index) => _buildStationGridTile(stations[index], theme, vm),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildStationTile(RadioStation station, ThemeData theme, RadioViewModel vm) {
    final playerVM = context.read<PlayerViewModel>();
    final bool isAvailable = station.isAvailable;
    
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.4,
      child: ListTile(
        dense: true,
        leading: _buildFavicon(station, theme),
        title: Text(
          station.name, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 13,
            decoration: isAvailable ? null : TextDecoration.lineThrough,
          )
        ),
        subtitle: Row(
          children: [
            Text('${station.country ?? "Global"} • ${station.bitrate}kbps', style: const TextStyle(fontSize: 10)),
            const Spacer(),
            const Icon(Icons.thumb_up_alt_outlined, size: 10, color: Colors.white38),
            const SizedBox(width: 4),
            Text(station.votes.toString(), style: const TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(station.isFavorite ? Icons.library_add_check : Icons.library_add, 
               color: station.isFavorite ? theme.colorScheme.primary : null, size: 18),
          onPressed: () => vm.toggleFavorite(station),
        ),
        onTap: () => vm.playStation(station, playerVM, isAvailable: isAvailable),
      ),
    );
  }

  Widget _buildStationGridTile(RadioStation station, ThemeData theme, RadioViewModel vm) {
    final playerVM = context.read<PlayerViewModel>();
    final bool isAvailable = station.isAvailable;
    final onSurface = theme.colorScheme.onSurface;

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
                decoration: isAvailable ? null : TextDecoration.lineThrough,
              )
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${station.country ?? "Global"} • ${station.bitrate}k', 
                    style: TextStyle(fontSize: 9, color: onSurface.withValues(alpha: 0.38)),
                    maxLines: 1,
                  ),
                ),
                const Icon(Icons.thumb_up_alt_outlined, size: 8, color: Colors.white24),
                const SizedBox(width: 2),
                Text(station.votes.toString(), style: const TextStyle(fontSize: 8, color: Colors.white24)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavicon(RadioStation station, ThemeData theme, {bool large = false}) {
    final url = station.favicon;
    return Stack(
      children: [
        Container(
          width: large ? double.infinity : 32,
          height: large ? double.infinity : 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(large ? 12 : 4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(large ? 12 : 4),
            child: url != null && url.isNotEmpty
                ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.radio, size: large ? 48 : 16))
                : Icon(Icons.radio, size: large ? 48 : 16),
          ),
        ),
        if (station.lastCheck != null)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: large ? 12 : 8,
              height: large ? 12 : 8,
              decoration: BoxDecoration(
                color: station.isAvailable ? Colors.greenAccent : Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  void _showManualStationDialog(RadioViewModel vm, ThemeData theme) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Add Manual Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Station Name')),
            const SizedBox(height: 8),
            TextField(controller: urlController, decoration: const InputDecoration(hintText: 'Stream URL (http://...)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                vm.addManualStation(nameController.text, urlController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSearch extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool expanded;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _ExpandableSearch({
    required this.controller,
    required this.focusNode,
    required this.expanded,
    required this.onToggle,
    required this.onSubmitted,
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
                  hintText: 'Search...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                onSubmitted: onSubmitted,
              ),
            ),
        ],
      ),
    );
  }
}
