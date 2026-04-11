class RecordingItem {
  final String id;
  final String profileId; // ✅ NEW
  final String modeId;
  final int level;
  final String filePath;
  final DateTime createdAt;

  RecordingItem({
    required this.id,
    required this.profileId,
    required this.modeId,
    required this.level,
    required this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileId': profileId,
        'modeId': modeId,
        'level': level,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RecordingItem.fromJson(Map<String, dynamic> json) => RecordingItem(
        id: (json['id'] ?? '').toString(),
        profileId: (json['profileId'] ?? 'unknown').toString(),
        modeId: (json['modeId'] ?? '').toString(),
        level: (json['level'] ?? 0) is int ? json['level'] : int.tryParse('${json['level']}') ?? 0,
        filePath: (json['filePath'] ?? '').toString(),
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      );
}