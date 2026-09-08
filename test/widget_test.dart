import 'package:flutter_test/flutter_test.dart';
import 'package:mutante_radio/radio_service.dart';

void main() {
  test('NowPlaying.fromStatusJson lê música, artista, capa e letra', () {
    final np = NowPlaying.fromStatusJson({
      'playing': {'name': 'Ministry', 'title': 'Senor Peligro'},
      'song_data': {'cover': 'https://x/cover.jpg', 'lyric': 'linha 1\nlinha 2'},
    });
    expect(np.artist, 'Ministry');
    expect(np.title, 'Senor Peligro');
    expect(np.cover, 'https://x/cover.jpg');
    expect(np.lyric, 'linha 1\nlinha 2');
  });

  test('NowPlaying.fromStatusJson cai no fallback quando vazio', () {
    final np = NowPlaying.fromStatusJson({});
    expect(np.artist, 'Mutante Radio');
    expect(np.title, 'Ao vivo');
    expect(np.lyric, isNull);
  });
}
