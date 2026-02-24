import 'package:hive/hive.dart';
import '../models/parent_profile.dart';
import '../models/recording_item.dart';
import '../models/app_settings.dart';

class LocalDb {
  static const _boxName = 'app_box';
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ---------------- Profile ----------------
  static ParentProfile? getProfile() {
    final data = _box.get('profile');
    if (data == null) return null;
    return ParentProfile.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<void> saveProfile(ParentProfile profile) async {
    await _box.put('profile', profile.toJson());
  }

  // ---------------- Recordings ----------------
  static List<RecordingItem> getRecordings() {
    final list = _box.get('recordings', defaultValue: []);
    final raw = List.from(list);
    return raw
        .map((e) => RecordingItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> addRecording(RecordingItem item) async {
    final current = _box.get('recordings', defaultValue: []);
    final updated = List.from(current)..add(item.toJson());
    await _box.put('recordings', updated);
  }

  static Future<void> deleteRecording(String id) async {
    final items = getRecordings();
    final updated = items.where((e) => e.id != id).map((e) => e.toJson()).toList();
    await _box.put('recordings', updated);
  }

  // ---------------- Settings ----------------
  static AppSettings getSettings() {
    final data = _box.get('settings');
    if (data == null) return AppSettings.defaults();
    return AppSettings.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await _box.put('settings', settings.toJson());
  }

  // ---------------- Reset All ----------------
  static Future<void> resetAll() async {
    await _box.delete('profile');
    await _box.delete('recordings');
    await _box.delete('settings');
  }
}
