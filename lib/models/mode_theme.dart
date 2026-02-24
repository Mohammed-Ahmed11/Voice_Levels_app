import 'package:flutter/material.dart';

class ModeTheme {
  final String id;
  final String title;
  final String backgroundImage;
  final Color accent;
  final double overlayOpacity;

  const ModeTheme({
    required this.id,
    required this.title,
    required this.backgroundImage,
    required this.accent,
    this.overlayOpacity = 0.35,
  });

  static ModeTheme fromId(String id) {
    switch (id) {
      case '1':
        return const ModeTheme(
          id: '1',
          title: 'Classic',
          backgroundImage: 'assets/images/mode-1.png',
          accent: Color(0xFF00C2FF),
          overlayOpacity: 0.28,
        );
      case '2':
        return const ModeTheme(
          id: '2',
          title: 'Rounded',
          backgroundImage: 'assets/images/mode-2.png',
          accent: Color(0xFFFFC107),
          overlayOpacity: 0.30,
        );
      case '3':
        return const ModeTheme(
          id: '3',
          title: 'Progress',
          backgroundImage: 'assets/images/mode-3.png',
          accent: Color(0xFF7C4DFF),
          overlayOpacity: 0.34,
        );
      case '4':
        return const ModeTheme(
          id: '4',
          title: 'Playful',
          backgroundImage: 'assets/images/mode-4.png',
          accent: Color(0xFF00E676),
          overlayOpacity: 0.26,
        );
      default:
        return const ModeTheme(
          id: '1',
          title: 'Classic',
          backgroundImage: 'assets/images/mode-1.png',
          accent: Color(0xFF00C2FF),
          overlayOpacity: 0.28,
        );
    }
  }
}
