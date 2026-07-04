import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/data/database/radio_database.dart';
import 'package:provider/provider.dart';
import 'package:aulos/features/radio/widgets/expandable_search.dart';
import 'package:aulos/features/radio/widgets/radio_station_info_drawer.dart';
import 'package:aulos/features/radio/widgets/radio_station_grid_tile.dart';
import 'package:aulos/features/radio/widgets/radio_station_list_tile.dart';

class RadioBrowserScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RadioBrowserScreen({super.key, this.onBack});

  @override
  State<RadioBrowserScreen> createState() => _RadioBrowserScreenState();
}

enum _DiscoveryTab { genre, country, language }

class _RadioBrowserScreenState extends State<RadioBrowserScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearching = false;
  bool _searchExpanded = false;
  _DiscoveryTab _activeTab = _DiscoveryTab.genre;
  String? _selectedDetailTitle;
  RadioStation? _selectedStationForInfo;

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
    super.build(context);
    final radioVM = context.watch<RadioViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final settingsVM = context.watch<settings.SettingsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _selectedStationForInfo != null
          ? RadioStationInfoDrawer(station: _selectedStationForInfo!)
          : null,
      body: Column(
        children: [
          _buildSubBar(radioVM, theme),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                onRefresh: () => radioVM.refresh(),
                child: _buildBody(radioVM, playerVM, settingsVM, theme),
              ),
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
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
              ),
            ),
            ExpandableSearch(
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
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () => vm.refresh(),
              tooltip: 'Refresh Discovery',
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
          vm.allCountries.map((c) => c['name']?.toString() ?? 'Unknown').toList(),
          theme,
          (val) {
            setState(() => _selectedDetailTitle = 'COUNTRY: ${val.toUpperCase()}');
            vm.browseByCountry(val).then((_) => vm.checkHealthForBrowseResults());
          }
        );
      case _DiscoveryTab.language:
        return _buildGrid(
          vm.allLanguages.map((l) => l['name']?.toString() ?? 'Unknown').toList(),
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
                  itemBuilder: (context, index) => RadioStationListTile(station: stations[index], vm: vm),
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
                itemBuilder: (context, index) {
                  final station = stations[index];
                  return RadioStationGridTile(
                    station: station,
                    vm: vm,
                    onInfoPressed: () {
                      setState(() {
                        _selectedStationForInfo = station;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scaffoldKey.currentState?.openEndDrawer();
                      });
                    },
                  );
                },
              );
            }
          ),
        ),
      ],
    );
  }


}
