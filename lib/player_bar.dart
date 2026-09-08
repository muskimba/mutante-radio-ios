import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'radio_service.dart';

/// Barra fixa embaixo (substitui o player do site).
class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radio = RadioService.instance;
    return AnimatedBuilder(
      animation: radio,
      builder: (context, _) {
        final np = radio.nowPlaying;
        return Material(
          color: const Color(0xFF1B1B1B),
          child: InkWell(
            onTap: onTap,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        np.cover,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          color: Colors.white10,
                          child: const Icon(Icons.radio, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            np.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            np.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: radio.playerState,
                      builder: (context, snap) {
                        final st = snap.data;
                        final playing = st?.playing ?? false;
                        final busy = st?.processingState == ProcessingState.loading ||
                            st?.processingState == ProcessingState.buffering;
                        return IconButton(
                          iconSize: 34,
                          onPressed: radio.toggle,
                          icon: busy
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(playing ? Icons.stop_circle : Icons.play_circle_fill),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
