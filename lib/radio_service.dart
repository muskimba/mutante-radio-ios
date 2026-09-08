import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'config.dart';

class NowPlaying {
  const NowPlaying({
    required this.artist,
    required this.title,
    required this.cover,
    this.lyric,
  });

  final String artist;
  final String title;
  final String cover;
  final String? lyric;

  static const initial = NowPlaying(
    artist: Config.stationName,
    title: 'Ao vivo',
    cover: Config.fallbackCover,
  );

  factory NowPlaying.fromStatusJson(Map<String, dynamic> json) {
    final playing = (json['playing'] as Map?) ?? const {};
    final songData = (json['song_data'] as Map?) ?? const {};
    final cover = (songData['cover'] as String?) ?? '';
    final lyric = (songData['lyric'] as String?)?.trim();
    return NowPlaying(
      artist: (playing['name'] as String?)?.trim().isNotEmpty == true
          ? (playing['name'] as String).trim()
          : Config.stationName,
      title: (playing['title'] as String?)?.trim().isNotEmpty == true
          ? (playing['title'] as String).trim()
          : 'Ao vivo',
      cover: cover.isEmpty || cover.contains('not-found') ? Config.fallbackCover : cover,
      lyric: (lyric == null || lyric.isEmpty) ? null : lyric,
    );
  }
}

/// Player de áudio nativo + "tocando agora". Um único objeto global.
class RadioService extends ChangeNotifier {
  RadioService._();
  static final RadioService instance = RadioService._();

  final AudioPlayer _player = AudioPlayer();
  Timer? _pollTimer;
  bool _sourceLoaded = false;

  NowPlaying nowPlaying = NowPlaying.initial;

  AudioPlayer get player => _player;
  Stream<PlayerState> get playerState => _player.playerStateStream;
  bool get isPlaying => _player.playing;

  Future<void> start() async {
    await _loadSource();
    await _refresh();
    _pollTimer = Timer.periodic(Config.pollInterval, (_) => _refresh());
  }

  Future<void> _loadSource() async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(Config.streamUrl),
          tag: MediaItem(
            id: Config.streamUrl,
            title: nowPlaying.title,
            artist: nowPlaying.artist,
            artUri: Uri.tryParse(nowPlaying.cover),
          ),
        ),
      );
      _sourceLoaded = true;
    } catch (e) {
      debugPrint('stream load: $e');
    }
  }

  Future<void> _refresh() async {
    try {
      final res = await http.get(Uri.parse(Config.statusUrl));
      if (res.statusCode != 200) return;
      nowPlaying = NowPlaying.fromStatusJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await _player.stop(); // stream ao vivo: descarta o buffer
      await _loadSource();
    } else {
      if (!_sourceLoaded) await _loadSource();
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> setVolume(double v) => _player.setVolume(v);

  @override
  void dispose() {
    _pollTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
