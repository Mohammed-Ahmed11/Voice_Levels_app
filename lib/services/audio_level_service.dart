import 'dart:async';
import 'package:noise_meter/noise_meter.dart';

class AudioLevelService {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _sub;

  final StreamController<double> _controller =
      StreamController<double>.broadcast();
  Stream<double> get levelStream => _controller.stream;

  void start() {
    _noiseMeter = NoiseMeter();

    // ✅ In newer versions, the stream is `noise`
    _sub = _noiseMeter!.noise.listen(
      (NoiseReading reading) {
        final db = reading.meanDecibel; // typical ~ 30..90
        final normalized = ((db - 30) / 60).clamp(0.0, 1.0);
        _controller.add(normalized);
      },
      onError: (e) {
        // لو حصل أي error من المايك
      },
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _noiseMeter = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  static int toLevel(double normalized, {int maxLevel = 10}) {
    final lvl = (normalized * maxLevel).ceil().clamp(1, maxLevel);
    return lvl;
  }
}
