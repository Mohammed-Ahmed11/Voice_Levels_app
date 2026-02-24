class AppSettings {
  final String recordingQuality; // high | medium | low
  final int maxLevel; // 10 | 20
  final int countdownSeconds; // 0 | 3 | 5
  final bool soundEffects; // true/false

  const AppSettings({
    required this.recordingQuality,
    required this.maxLevel,
    required this.countdownSeconds,
    required this.soundEffects,
  });

  factory AppSettings.defaults() => const AppSettings(
        recordingQuality: 'medium',
        maxLevel: 10,
        countdownSeconds: 3,
        soundEffects: true,
      );

  AppSettings copyWith({
    String? recordingQuality,
    int? maxLevel,
    int? countdownSeconds,
    bool? soundEffects,
  }) {
    return AppSettings(
      recordingQuality: recordingQuality ?? this.recordingQuality,
      maxLevel: maxLevel ?? this.maxLevel,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      soundEffects: soundEffects ?? this.soundEffects,
    );
  }

  Map<String, dynamic> toJson() => {
        'recordingQuality': recordingQuality,
        'maxLevel': maxLevel,
        'countdownSeconds': countdownSeconds,
        'soundEffects': soundEffects,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        recordingQuality: (json['recordingQuality'] ?? 'medium').toString(),
        maxLevel: int.tryParse((json['maxLevel'] ?? 10).toString()) ?? 10,
        countdownSeconds: int.tryParse((json['countdownSeconds'] ?? 3).toString()) ?? 3,
        soundEffects: (json['soundEffects'] ?? true) == true,
      );
}
