import '../models/app_settings.dart';
import 'local_db.dart';

class SettingsService {
  static AppSettings getSettings() {
    return LocalDb.getSettings();
  }

  static Future<void> saveSettings(AppSettings s) async {
    await LocalDb.saveSettings(s);
  }
}
