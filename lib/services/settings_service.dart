import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

// ═══════════════════════════════════════════════════════════
//  SettingsService
//  • load()  → reads AppSettings from SharedPreferences
//  • save()  → persists AppSettings to SharedPreferences
// ═══════════════════════════════════════════════════════════

class SettingsService {
  static const _key = 'app_settings_v1';

  static Future<AppSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return AppSettings.defaults();
      final map = json.decode(raw) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  static Future<void> save(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, json.encode(settings.toJson()));
    } catch (_) {}
  }
}