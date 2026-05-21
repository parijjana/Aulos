import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:provider/provider.dart';
import '../widgets/music_library_view.dart';
import '../widgets/podcast_library_view.dart';
import '../widgets/radio_library_view.dart';

class LibraryHubScreen extends StatefulWidget {
  const LibraryHubScreen({super.key});

  @override
  State<LibraryHubScreen> createState() => _LibraryHubScreenState();
}

class _LibraryHubScreenState extends State<LibraryHubScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _hubTabController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<LibraryViewModel>();
    _hubTabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: viewModel.libraryTabIndex,
    );
    _hubTabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_hubTabController.indexIsChanging) return;
    context.read<LibraryViewModel>().setLibraryTabIndex(_hubTabController.index);
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _hubTabController.removeListener(_handleTabChange);
    _hubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _hubTabController,
                  isScrollable: true,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.onSurface,
                  unselectedLabelColor: onSurface.withValues(alpha: 0.38),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                  tabs: const [
                    Tab(text: 'MUSIC'),
                    Tab(text: 'PODCASTS'),
                    Tab(text: 'RADIO'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white10),
        Expanded(
          child: TabBarView(
            controller: _hubTabController,
            children: const [
              MusicLibraryView(),
              PodcastLibraryView(),
              RadioLibraryView(),
            ],
          ),
        ),
      ],
    );
  }
}
