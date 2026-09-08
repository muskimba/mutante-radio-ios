import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'radio_service.dart';

void showNowPlayingSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF161616),
    showDragHandle: true,
    builder: (_) => const _NowPlayingSheet(),
  );
}

class _NowPlayingSheet extends StatelessWidget {
  const _NowPlayingSheet();

  @override
  Widget build(BuildContext context) {
    final radio = RadioService.instance;
    return AnimatedBuilder(
      animation: radio,
      builder: (context, _) {
        final np = radio.nowPlaying;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    np.cover,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 220,
                      height: 220,
                      color: Colors.white10,
                      child: const Icon(Icons.radio, size: 80),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                np.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                np.artist,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              StreamBuilder<PlayerState>(
                stream: radio.playerState,
                builder: (context, snap) {
                  final playing = snap.data?.playing ?? false;
                  return FilledButton.icon(
                    onPressed: radio.toggle,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    icon: Icon(playing ? Icons.stop : Icons.play_arrow),
                    label: Text(playing ? 'Parar' : 'Ouvir ao vivo'),
                  );
                },
              ),
              const SizedBox(height: 12),
              StreamBuilder<double>(
                stream: radio.player.volumeStream,
                builder: (context, snap) => Row(
                  children: [
                    const Icon(Icons.volume_down, size: 20),
                    Expanded(
                      child: Slider(
                        value: snap.data ?? 1.0,
                        onChanged: radio.setVolume,
                      ),
                    ),
                    const Icon(Icons.volume_up, size: 20),
                  ],
                ),
              ),
              if (np.lyric != null) ...[
                const Divider(height: 32),
                const Text('Letra', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  np.lyric!,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
