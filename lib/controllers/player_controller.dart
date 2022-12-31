import 'package:audioplayers/audioplayers.dart';

late AudioPlayer _player;

bool _isPlayig = false;

class PlayerController {
  PlayerController(int surah) {
    _initPlayer(surah);
  }

  Future<void> _initPlayer(int surah) async {
    String s = surah.toString().padLeft(3, '0');
    _player = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    await _player.setUrl('https://download.quranicaudio.com/qdc/saud_ash-shuraym/murattal/$s.mp3');
  }

  get isPlaying => _isPlayig;

  void pp() {}

  void resume() {}

  void pause() {}

  void seek(Duration d) {
    _player.seek(d);
  }
}
