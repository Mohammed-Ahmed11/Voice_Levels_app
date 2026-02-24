import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  int _bitRateFromQuality(String quality) {
    switch (quality) {
      case 'high':
        return 192000;
      case 'low':
        return 64000;
      case 'medium':
      default:
        return 128000;
    }
  }

  Future<String?> startRecording({required String quality}) async {
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) return null;

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/recordings');
    if (!folder.existsSync()) folder.createSync(recursive: true);

    final filePath = '${folder.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: _bitRateFromQuality(quality),
        sampleRate: 44100,
      ),
      path: filePath,
    );

    return filePath;
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
  }

  Future<bool> get isRecording async => _recorder.isRecording();
}
