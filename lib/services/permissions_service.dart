import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> ensureAudioPermissions() async {
    final mic = await Permission.microphone.request();
    // Android 13+ ممكن تحتاج media/audio حسب تخزينك، لكن هنا بنكتب داخل app dir.
    return mic.isGranted;
  }
}
