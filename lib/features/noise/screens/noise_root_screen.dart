import 'package:flutter/material.dart';
import 'package:aulos/features/noise/models/noise_item.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/data/database/app_database.dart';
import 'package:provider/provider.dart';

class NoiseRootScreen extends StatefulWidget {
  const NoiseRootScreen({super.key});

  @override
  State<NoiseRootScreen> createState() => _NoiseRootScreenState();
}

class _NoiseRootScreenState extends State<NoiseRootScreen> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  int _activeTab = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _activeTab = index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final noiseVM = context.watch<NoiseViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 1000;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildUnifiedHeader(isWide, noiseVM),
              const SizedBox(height: 16),
              Expanded(
                child: isWide 
                  ? Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _NoiseMixerTab(noiseVM: noiseVM),
                        ),
                        VerticalDivider(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                        Expanded(
                          flex: 2,
                          child: _SavedMixesTab(noiseVM: noiseVM, isWide: true),
                        ),
                      ],
                    )
                  : PageView(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => _activeTab = index),
                      children: [
                        _NoiseMixerTab(noiseVM: noiseVM),
                        _SavedMixesTab(noiseVM: noiseVM),
                      ],
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnifiedHeader(bool isWide, NoiseViewModel noiseVM) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!isWide) ...[
            _buildNavButton('MIXER', 0, _activeTab == 0, theme),
            const SizedBox(width: 8),
            _buildNavButton('SAVED MIXES', 1, _activeTab == 1, theme),
          ],
          const Spacer(),
          // Text removed to reclaim vertical space
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
}

class _NoiseMixerTab extends StatefulWidget {
  final NoiseViewModel noiseVM;
  const _NoiseMixerTab({required this.noiseVM});

  @override
  State<_NoiseMixerTab> createState() => _NoiseMixerTabState();
}

class _NoiseMixerTabState extends State<_NoiseMixerTab> {
  final ScrollController _tabScrollController = ScrollController();

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noiseVM = widget.noiseVM;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: NoiseCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterPill(
                          cat.name.toUpperCase(), 
                          noiseVM.selectedCategory == cat, 
                          theme,
                          () => noiseVM.setCategory(cat),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: noiseVM.filteredItems.length,
            itemBuilder: (context, index) {
              final item = noiseVM.filteredItems[index];
              final isActive = noiseVM.activeVolumes.containsKey(item.id);
              final volume = noiseVM.activeVolumes[item.id] ?? 0.5;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? theme.colorScheme.primary.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => noiseVM.toggleSound(item.id),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon, 
                            size: 18,
                            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                letterSpacing: 1.0,
                              ),
                            ),
                            if (isActive)
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                  thumbColor: theme.colorScheme.primary,
                                ),
                                child: Slider(
                                  value: volume,
                                  onChanged: (val) => noiseVM.setVolume(item.id, val),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
}

class _SavedMixesTab extends StatelessWidget {
  final NoiseViewModel noiseVM;
  final bool isWide;
  const _SavedMixesTab({required this.noiseVM, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (noiseVM.savedMixes.isEmpty && !noiseVM.isMixerActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_motion_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            const SizedBox(height: 16),
            Text('No saved mixes.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.24), fontSize: 11)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Text(
                'SAVED MIXES',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (noiseVM.isMixerActive)
                IconButton(
                  onPressed: () => _showSaveDialog(context, noiseVM),
                  icon: const Icon(Icons.save_alt_rounded, size: 16),
                  tooltip: 'Save Current Mix',
                  visualDensity: VisualDensity.compact,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: noiseVM.savedMixes.length,
            itemBuilder: (context, index) {
              final mix = noiseVM.savedMixes[index];
              return InkWell(
                onTap: () => noiseVM.playMix(mix),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mix.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 14),
                            onPressed: () => noiseVM.deleteMix(mix.id),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Icon(Icons.play_circle_outline, size: 14),
                          SizedBox(width: 8),
                          Text('PLAY MIX', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSaveDialog(BuildContext context, NoiseViewModel vm) {
    final controller = TextEditingController();
    final activeNames = vm.allItems
        .where((i) => vm.activeVolumes.containsKey(i.id))
        .map((i) => i.title)
        .join(' & ');
    controller.text = activeNames;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Ambient Mix'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter mix name...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.saveCurrentMix(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
