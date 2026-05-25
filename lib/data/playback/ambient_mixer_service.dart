import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';
import 'dart:math';

class AmbientMixerService {
  final Map<String, AudioPlayer> _players = {};
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.game,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: false,
    ));
    
    _isInitialized = true;
  }

  Future<void> preloadSound(String id, String url) async {
    await _ensureInitialized();
    if (!_players.containsKey(id)) {
      final player = AudioPlayer();
      _players[id] = player;
      // Load once and keep ready in LOOP mode
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(0);
    }
  }

  Future<void> setSound(String id, String url, {double volume = 0.5, bool play = false}) async {
    await _ensureInitialized();

    if (!_players.containsKey(id)) {
      await preloadSound(id, url);
    }

    final player = _players[id]!;
    
    if (play) {
      await player.setVolume(volume);
      // Ensure loop mode is ALWAYS on before playing
      await player.setLoopMode(LoopMode.one);
      
      final duration = player.duration;
      if (duration != null && player.position == Duration.zero) {
        final randomMs = Random().nextInt(duration.inMilliseconds);
        await player.seek(Duration(milliseconds: randomMs));
      }
      unawaited(player.play());
    } else {
      await player.stop();
      await player.seek(Duration.zero);
    }
  }

  Future<void> setVolume(String id, double volume) async {
    final player = _players[id];
    if (player != null) {
      await player.setVolume(volume);
    }
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
      await player.seek(Duration.zero);
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
