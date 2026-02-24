import 'package:audioplayers/audioplayers.dart';

class PlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playFile(String path) async {
    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  Future<void> stop() async => _player.stop();

  void dispose() => _player.dispose();
}
