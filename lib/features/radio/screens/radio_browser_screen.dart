import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/data/library/radio_browser_service.dart';
import 'package:provider/provider.dart';

class RadioBrowserScreen extends StatefulWidget {
  const RadioBrowserScreen({super.key});

  @override
  State<RadioBrowserScreen> createState() => _RadioBrowserScreenState();
}

class _RadioBrowserScreenState extends State<RadioBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchHeader(radioVM, theme),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBody(radioVM, playerVM, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(RadioViewModel vm, PlayerViewModel playerVM, ThemeData theme) {
    if (vm.isLoading && vm.categories.isEmpty && vm.browseResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load stations', style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: vm.refresh, child: const Text('RETRY')),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: _selectedTag != null
          ? _buildCategoryDetailView(vm, playerVM, theme)
          : _isSearching
              ? _buildSearchResults(vm, playerVM, theme)
              : _buildDiscoveryHome(vm, theme),
    );
  }

  Widget _buildSearchHeader(RadioViewModel vm, ThemeData theme) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (_isSearching || _selectedTag != null)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _selectedTag = null;
                  });
                  _searchController.clear();
                },
              ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search 40,000+ stations...',
                  border: InputBorder.none,
                  prefixIcon: (_isSearching || _selectedTag != null) ? null : const Icon(Icons.search, size: 20),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                onChanged: (val) {
                  if (!_isSearching && val.isNotEmpty) {
                    setState(() => _isSearching = true);
                  }
                },
                onSubmitted: (val) => vm.search(val),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_link, color: theme.colorScheme.primary),
              onPressed: () => _showManualStationDialog(vm, theme),
              tooltip: 'Add Manual URL',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryHome(RadioViewModel vm, ThemeData theme) {
    return ListView(
      children: [
        _buildSectionHeader(theme, 'BROWSE BY GENRE'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: vm.categories.length,
          itemBuilder: (context, index) {
            final cat = vm.categories[index];
            return _buildCategoryChip(cat, theme, vm);
          },
        ),
        const SizedBox(height: 32),
        _buildSectionHeader(theme, 'TOP RATED STATIONS'),
        _buildTopStationsGrid(vm, theme),
      ],
    );
  }

  Widget _buildCategoryChip(RadioCategory cat, ThemeData theme, RadioViewModel vm) {
    return InkWell(
      onTap: () {
        setState(() => _selectedTag = cat.name);
        vm.browseCategory(cat.name);
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          cat.name.toUpperCase(),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
      ),
    );
  }

  Widget _buildTopStationsGrid(RadioViewModel vm, ThemeData theme) {
    if (vm.browseResults.isEmpty && !vm.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.white10),
              const SizedBox(height: 16),
              Text(
                'No stations found.',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
              ),
            ],
          ),
        ),
      );
    }

    // For simplicity, showing a list here. Can be changed to grid.
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.browseResults.length > 20 ? 20 : vm.browseResults.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      itemBuilder: (context, index) {
        final station = vm.browseResults[index];
        return _buildStationTile(station, theme, vm);
      },
    );
  }

  Widget _buildCategoryDetailView(RadioViewModel vm, PlayerViewModel playerVM, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'GENRE: ${_selectedTag!.toUpperCase()}'),
        Expanded(
          child: ListView.separated(
            itemCount: vm.browseResults.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final station = vm.browseResults[index];
              return _buildStationTile(station, theme, vm);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStationTile(RadioStation station, ThemeData theme, RadioViewModel vm) {
    final playerVM = context.read<PlayerViewModel>();
    return ListTile(
      dense: true,
      leading: _buildFavicon(station.favicon, theme),
      title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text('${station.country ?? "Global"} • ${station.bitrate}kbps', style: const TextStyle(fontSize: 10)),
      trailing: IconButton(
        icon: Icon(station.isFavorite ? Icons.favorite : Icons.favorite_border, 
             color: station.isFavorite ? Colors.pinkAccent : null, size: 18),
        onPressed: () => vm.toggleFavorite(station),
      ),
      onTap: () => vm.playStation(station, playerVM),
    );
  }

  Widget _buildSearchResults(RadioViewModel vm, PlayerViewModel playerVM, ThemeData theme) {
    return ListView.separated(
      itemCount: vm.searchResults.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      itemBuilder: (context, index) {
        final station = vm.searchResults[index];
        return _buildStationTile(station, theme, vm);
      },
    );
  }

  Widget _buildFavicon(String? url, ThemeData theme) {
    return Container(
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
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
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
