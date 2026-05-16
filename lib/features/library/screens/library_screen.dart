import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:provider/provider.dart';

import '../widgets/library_header.dart';
import '../widgets/library_category_list.dart';
import '../widgets/library_sub_list.dart';
import '../widgets/library_grid_view.dart';
import '../widgets/library_orbit_view.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  late ScrollController _scrollController;
  String? _currentKey;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 6, vsync: this);
    _subTabController.addListener(_handleTabSelection);
    _scrollController = ScrollController();
  }

  void _handleTabSelection() {
    if (_subTabController.indexIsChanging) return;
    final viewModel = context.read<LibraryViewModel>();
    
    if (_scrollController.hasClients) {
      viewModel.saveScrollOffset(_scrollController.offset);
    }
    
    switch (_subTabController.index) {
      case 0: viewModel.setMode(LibraryMode.folders); break;
      case 1: viewModel.setMode(LibraryMode.artists); break;
      case 2: viewModel.setMode(LibraryMode.albums); break;
      case 3: viewModel.setMode(LibraryMode.genres); break;
      case 4: viewModel.setMode(LibraryMode.years); break;
      case 5: viewModel.setMode(LibraryMode.playlists); break;
    }
  }

  @override
  void dispose() {
    _subTabController.removeListener(_handleTabSelection);
    _subTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LibraryViewModel>();
    final theme = Theme.of(context);

    if (_currentKey != viewModel.currentScrollKey) {
      _currentKey = viewModel.currentScrollKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final offset = viewModel.getScrollOffset();
          final max = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(offset.clamp(0.0, max));
        }
      });
    }

    return PopScope(
      canPop: viewModel.isAtRoot,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_scrollController.hasClients) {
          viewModel.saveScrollOffset(_scrollController.offset);
        }
        viewModel.goBack();
      },
      child: Column(
        children: [
          LibraryHeader(
            viewModel: viewModel,
            scrollController: _scrollController,
            subTabController: _subTabController,
          ),
          Expanded(
            child: viewModel.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _buildContent(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LibraryViewModel viewModel) {
    switch (viewModel.viewType) {
      case settings.LibraryViewType.list:
        return viewModel.isAtRoot
            ? LibraryCategoryList(viewModel: viewModel, scrollController: _scrollController)
            : LibrarySubList(viewModel: viewModel, scrollController: _scrollController);
      case settings.LibraryViewType.grid:
        return LibraryGridView(viewModel: viewModel, scrollController: _scrollController);
      case settings.LibraryViewType.orbit:
        return LibraryOrbitView(viewModel: viewModel);
    }
  }
}
