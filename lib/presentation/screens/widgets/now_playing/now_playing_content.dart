import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';
import 'strategies/now_playing_strategy.dart';
import 'strategies/music_strategy.dart';
import 'strategies/audiobook_strategy.dart';
import 'strategies/podcast_strategy.dart';
import 'strategies/radio_strategy.dart';
import 'strategies/noise_strategy.dart';

class NowPlayingContent extends StatelessWidget {
  const NowPlayingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final playerVM = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);
    final strategy = _getStrategy(playerVM.currentMediaType);

    // FIX: Strategy builders return regular box widgets, so we MUST 
    // wrap them in a SliverToBoxAdapter for use in the slivers list.
    return SliverToBoxAdapter(
      child: strategy.buildContent(context, playerVM, theme),
    );
  }

  NowPlayingStrategy _getStrategy(MediaType type) {
    switch (type) {
      case MediaType.music: return MusicStrategy();
      case MediaType.audiobook: return AudiobookStrategy();
      case MediaType.podcast: return PodcastStrategy();
      case MediaType.radio: return RadioStrategy();
      case MediaType.noise: return NoiseStrategy();
    }
  }
}
