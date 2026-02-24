import 'package:flutter/material.dart';

class LevelMeter extends StatelessWidget {
  final double value; // 0..1
  final String modeId;

  const LevelMeter({super.key, required this.value, required this.modeId});

  @override
  Widget build(BuildContext context) {
    // اختلاف الشكل حسب المود
    final rounded = modeId == '2' || modeId == '4';
    final height = modeId == '3' ? 22.0 : 16.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(rounded ? 18 : 6),
      child: LinearProgressIndicator(
        minHeight: height,
        value: value,
      ),
    );
  }
}
