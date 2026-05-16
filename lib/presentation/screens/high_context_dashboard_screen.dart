import 'package:flutter/material.dart';
import 'package:localaudioplayer/features/library/screens/library_screen.dart';
import 'package:localaudioplayer/presentation/screens/now_playing_screen.dart';
import 'package:localaudioplayer/presentation/viewmodels/display_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:localaudioplayer/presentation/screens/widgets/queue_tab.dart';
import 'package:provider/provider.dart';

class HighContextDashboardScreen extends StatefulWidget {
  const HighContextDashboardScreen({super.key});

  @override
  State<HighContextDashboardScreen> createState() =>
      _HighContextDashboardScreenState();
}

class _HighContextDashboardScreenState extends State<HighContextDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _libraryTabController;

  @override
  void initState() {
    super.initState();
    _libraryTabController = TabController(length: 5, vsync: this);
    _libraryTabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_libraryTabController.indexIsChanging) return;
    final viewModel = context.read<LibraryViewModel>();
    switch (_libraryTabController.index) {
      case 0:
        viewModel.setMode(LibraryMode.folders);
        break;
      case 1:
        viewModel.setMode(LibraryMode.artists);
        break;
      case 2:
        viewModel.setMode(LibraryMode.albums);
        break;
      case 3:
        viewModel.setMode(LibraryMode.genres);
        break;
      case 4:
        viewModel.setMode(LibraryMode.years);
        break;
    }
  }

  @override
  void dispose() {
    _libraryTabController.removeListener(_handleTabSelection);
    _libraryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayVM = context.watch<DisplayViewModel>();
    final playerVM = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(theme),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, displayVM),
                Expanded(
                  child: Row(
                    children: [
                      // Left: Library (60% width)
                      Expanded(flex: 6, child: _buildLibrarySection(theme)),
                      // Right: Queue (40% width)
                      Expanded(flex: 4, child: _buildQueueSection(theme)),
                    ],
                  ),
                ),
                _buildDashboardMiniPlayer(context, playerVM, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            Colors.black,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DisplayViewModel displayVM) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AULOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const Text(
                'HIGH CONTEXT DASHBOARD',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildVolumeControl(context.watch<PlayerViewModel>()),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.close_fullscreen, color: Colors.white70),
            onPressed: displayVM.toggleMode,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl(PlayerViewModel vm) {
    return Row(
      children: [
        const Icon(Icons.volume_up, color: Colors.white38, size: 18),
        SizedBox(
          width: 120,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              activeTrackColor: Colors.cyanAccent,
              inactiveTrackColor: Colors.white10,
            ),
            child: Slider(value: vm.volume, onChanged: vm.setVolume),
          ),
        ),
      ],
    );
  }

  Widget _buildLibrarySection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: GlassCard(
        opacity: 0.05,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            TabBar(
              controller: _libraryTabController,
              isScrollable: true,
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(text: 'FOLDERS'),
                Tab(text: 'ARTISTS'),
                Tab(text: 'ALBUMS'),
                Tab(text: 'GENRES'),
                Tab(text: 'YEARS'),
              ],
            ),
            const Expanded(child: LibraryScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
      child: const GlassCard(
        opacity: 0.05,
        padding: EdgeInsets.zero,
        child: QueueTab(),
      ),
    );
  }

  Widget _buildDashboardMiniPlayer(
    BuildContext context,
    PlayerViewModel vm,
    ThemeData theme,
  ) {
    final track = vm.currentTrack;
    return GestureDetector(
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const NowPlayingScreen()),
      ),
      child: GlassCard(
        blur: 30,
        opacity: 0.15,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Row(
          children: [
            _buildMiniArt(track),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track?.title ?? 'No Track Playing',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Unknown Artist',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            _buildMiniProgressBar(vm),
            const SizedBox(width: 24),
            IconButton(
              icon: Icon(
                vm.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white,
                size: 42,
              ),
              onPressed: vm.isPlaying ? vm.pause : vm.play,
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white70,
                size: 32,
              ),
              onPressed: vm.skipNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniArt(dynamic track) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Icon(Icons.music_note, color: Colors.white30),
    );
  }

  Widget _buildMiniProgressBar(PlayerViewModel vm) {
    final progress = vm.duration.inMilliseconds > 0
        ? vm.position.inMilliseconds / vm.duration.inMilliseconds
        : 0.0;
    return Container(
      width: 200,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
