import 'package:hive/hive.dart';
import '../models/parent_profile.dart';
import '../models/recording_item.dart';
import '../models/app_settings.dart';

class LocalDb {
  static const _boxName = 'app_box';
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);

    // migration: لو عندك profile قديم واحد -> حوّله لقائمة profiles
    final old = _box.get('profile');
    final profiles = _box.get('profiles');
    if (old != null && profiles == null) {
      final p = ParentProfile.fromJson(Map<String, dynamic>.from(old));
      await _box.put('profiles', [p.toJson()]);
      await _box.put('activeProfileId', p.id);
      await _box.delete('profile');
    }
  }

  // ---------------- Profiles ----------------
  static List<ParentProfile> getProfiles() {
    final list = _box.get('profiles', defaultValue: []);
    final raw = List.from(list);
    return raw.map((e) => ParentProfile.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static String? getActiveProfileId() {
    final v = _box.get('activeProfileId');
    return v == null ? null : v.toString();
  }

  static Future<void> setActiveProfileId(String id) async {
    await _box.put('activeProfileId', id);
  }

  static Future<void> upsertProfile(ParentProfile profile) async {
    final items = getProfiles();
    final idx = items.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      items[idx] = profile;
    } else {
      items.add(profile);
    }
    await _box.put('profiles', items.map((e) => e.toJson()).toList());
    await setActiveProfileId(profile.id);
  }

  // ---------------- Recordings ----------------
  static List<RecordingItem> getRecordings({String? profileId}) {
    final list = _box.get('recordings', defaultValue: []);
    final raw = List.from(list);

    final all = raw
        .map((e) => RecordingItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (profileId == null) return all;
    return all.where((r) => r.profileId == profileId).toList();
  }

  static Future<void> addRecording(RecordingItem item) async {
    final current = _box.get('recordings', defaultValue: []);
    final updated = List.from(current)..add(item.toJson());
    await _box.put('recordings', updated);
  }

  static Future<void> deleteRecording(String id) async {
    final list = _box.get('recordings', defaultValue: []);
    final raw = List.from(list);
    final items = raw.map((e) => RecordingItem.fromJson(Map<String, dynamic>.from(e))).toList();
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
    await _box.delete('profiles');
    await _box.delete('activeProfileId');
    await _box.delete('recordings');
    await _box.delete('settings');
  }
}