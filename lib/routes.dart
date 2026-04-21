import 'package:flutter/material.dart';

import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mode_select_screen.dart';
import 'screens/recorder_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recordings_screen.dart';
import 'screens/recording_details_screen.dart';
import 'screens/settings_screen.dart';
import '../widgets/recorder_modes/arabic_letters_mode.dart';

class AppRoutes {
  // ---------------- Main Routes ----------------
  static const loading = '/';
  static const home = '/home';
  static const modeSelect = '/modes';
  static const recorder = '/recorder';
  static const profile = '/profile';
  static const recordings = '/recordings';
  static const recordingDetails = '/recording_details';
  static const settings = '/settings';
  static const arabicLetters = '/arabic-letters';

  // ---------------- Route Map ----------------
  static Map<String, WidgetBuilder> get map => {
    loading: (_) => const LoadingScreen(), // 👈 Loading Page
    home: (_) => const HomeScreen(),
    modeSelect: (_) => const ModeSelectScreen(),
    recorder: (_) => const RecorderScreen(),
    profile: (_) => const ProfileScreen(),
    recordings: (_) => const RecordingsScreen(),
    recordingDetails: (_) => const RecordingDetailsScreen(),
    settings: (_) => const SettingsScreen(),
    // ✅ NEW MODE (Arabic Letters)
    arabicLetters: (_) => const ArabicLettersModeScreen(),
  };
}
