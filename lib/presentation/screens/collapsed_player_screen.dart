import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as domain;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

class CollapsedPlayerScreen extends StatelessWidget {
  const CollapsedPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerVM = context.watch<PlayerViewModel>();
    final displayVM = context.watch<DisplayViewModel>();
    final track = playerVM.currentTrack;
    final double screenWidth = MediaQuery.of(context).size.width;

    final bool isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onPanStart: isDesktop ? (details) => windowManager.startDragging() : null,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.cyanAccent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildMiniArt(track?.coverArt),
              const SizedBox(width: 12),
              // Scrolling Track Info
              Expanded(
                child: _ScrollingText(
                  text: track != null
                      ? '${track.title} â€¢ ${playerVM.currentArtistName} â€¢ ${playerVM.currentAlbumName}'
                      : 'No Track Playing',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Replicated FAB Controls
              if (screenWidth >= 400) ...[
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: playerVM.isShuffle
                        ? Colors.cyanAccent
                        : Colors.white24,
                    size: 16,
                  ),
                  onPressed: playerVM.toggleShuffle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              if (screenWidth >= 360) ...[
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: playerVM.skipPrevious,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              IconButton(
                icon: Icon(
                  playerVM.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: playerVM.togglePlay,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              if (screenWidth >= 360) ...[
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: playerVM.skipNext,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
              if (screenWidth >= 400) ...[
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    playerVM.repeatMode == domain.RepeatMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    color: playerVM.repeatMode != domain.RepeatMode.off
                        ? Colors.cyanAccent
                        : Colors.white24,
                    size: 16,
                  ),
                  onPressed: playerVM.toggleRepeat,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
              if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) ...[
                const SizedBox(width: 16),
                // Window Controls
                IconButton(
                  icon: const Icon(
                    Icons.unfold_more_rounded,
                    color: Colors.cyanAccent,
                    size: 18,
                  ),
                  onPressed: () async {
                    displayVM.toggleCollapsed();
                    if (!kIsWeb && Platform.isWindows) {
                      await windowManager.setAlwaysOnTop(false);
                      await windowManager.setSize(const Size(1280, 720));
                      await windowManager.center();
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Restore',
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.redAccent.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  onPressed: () => windowManager.close(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Close',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniArt(Uint8List? art) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(6),
        image: art != null && art.isNotEmpty
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : null,
      ),
      child: art == null || art.isEmpty
          ? const Icon(Icons.music_note, color: Colors.white24, size: 18)
          : null,
    );
  }
}

class _ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _ScrollingText({required this.text, required this.style});

  @override
  State<_ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<_ScrollingText> {
  late ScrollController _scrollController;
  Timer? _timer;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleNextScroll(const Duration(seconds: 2)));
  }

  void _scheduleNextScroll(Duration delay) {
    _timer?.cancel();
    if (!mounted) return;
    _timer = Timer(delay, () => _scroll());
  }

  void _scroll() async {
    if (!mounted || !_scrollController.hasClients || _animating) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      _scheduleNextScroll(const Duration(seconds: 2));
      return;
    }

    _animating = true;
    final scrollDuration = Duration(milliseconds: (maxScroll * 30).toInt());
    await _scrollController.animateTo(
      maxScroll,
      duration: scrollDuration,
      curve: Curves.linear,
    );

    if (!mounted) return;
    _animating = false;

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted || !_scrollController.hasClients) return;
      _animating = true;
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
      if (!mounted) return;
      _animating = false;
      _scheduleNextScroll(const Duration(seconds: 2));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text, style: widget.style, maxLines: 1),
    );
  }
}
