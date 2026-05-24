import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radioVM = context.watch<RadioViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTopBar(radioVM, theme),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBody(radioVM, playerVM, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(RadioViewModel vm, ThemeData theme) {
    final bool showTabs = !_searchExpanded && !_isSearching && _selectedDetailTitle == null;

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          // 1. Back/Context Toggle (Left side)
          if (_selectedDetailTitle != null || _isSearching)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              onPressed: () => setState(() {
                _selectedDetailTitle = null;
                _isSearching = false;
                _searchExpanded = false;
                _searchController.clear();
              }),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else if (showTabs)
            Text(
              'EXPLORE RADIO',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          
          const SizedBox(width: 16),

          // 2. Tabs (Responsive Row)
          if (showTabs) ...[
            _buildTabButton('GENRE', _DiscoveryTab.genre, theme),
            const SizedBox(width: 4),
            _buildTabButton('REGION', _DiscoveryTab.country, theme),
            const SizedBox(width: 4),
            _buildTabButton('LANG', _DiscoveryTab.language, theme),
          ],
          
          const Spacer(),
          
          // 3. Expandable Search
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _searchExpanded ? 180 : 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search, size: 16, color: _searchExpanded ? theme.colorScheme.primary : null),
                  onPressed: () => setState(() {
                    _searchExpanded = !_searchExpanded;
                    if (_searchExpanded) _searchFocus.requestFocus();
                  }),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (_searchExpanded) ...[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 12),
                      onSubmitted: (val) {
                        if (val.isNotEmpty) {
                          setState(() => _isSearching = true);
                          vm.search(val);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        setState(() => _searchController.clear());
                      } else {
                        setState(() {
                          _isSearching = false;
                          _searchExpanded = false;
                          _searchController.clear();
                          _searchFocus.unfocus();
                        });
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 4. Manual Add
          IconButton(
            icon: const Icon(Icons.add_link, size: 20),
            onPressed: () => _showManualStationDialog(vm, theme),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Add Manual URL',
          ),

          const SizedBox(width: 12),

          // 5. Global BACK button (Replaces FIND MORE position)
          if (widget.onBack != null && !(_selectedDetailTitle != null || _isSearching))
            TextButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.library_music_outlined, size: 16),
              label: const Text('LIBRARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, _DiscoveryTab tab, ThemeData theme) {
    final isActive = _activeTab == tab;
    return InkWell(
      onTap: () => setState(() => _activeTab = tab),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isActive ? null : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RadioViewModel vm, PlayerViewModel playerVM, ThemeData theme) {
    if (vm.isLoading && vm.browseResults.isEmpty && vm.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isSearching) {
      return _buildStationList(vm.searchResults, theme, vm, 'SEARCH RESULTS');
    }

    if (_selectedDetailTitle != null) {
      return _buildStationList(vm.browseResults, theme, vm, _selectedDetailTitle!);
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
    return GridView.builder(
      key: PageStorageKey('radio_grid_${_activeTab.name}'),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
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

  Widget _buildStationList(List<RadioStation> stations, ThemeData theme, RadioViewModel vm, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.5)),
        ),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            itemCount: stations.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final station = stations[index];
              return _buildStationTile(station, theme, vm);
            },
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
        onTap: () => vm.playStation(station, playerVM),
      ),
    );
  }

  Widget _buildFavicon(RadioStation station, ThemeData theme) {
    final url = station.favicon;
    return Stack(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: url != null && url.isNotEmpty
                ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.radio, size: 16))
                : const Icon(Icons.radio, size: 16),
          ),
        ),
        if (station.lastCheck != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 8,
              height: 8,
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
