import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareAudioFile(String path) async {
    await Share.shareXFiles([XFile(path)], text: 'Voice Recording');
  }
}
