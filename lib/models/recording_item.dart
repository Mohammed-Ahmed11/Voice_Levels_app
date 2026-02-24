class RecordingItem {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final int level; // 1..N
  final String modeId; // 1..4

  RecordingItem({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.level,
    required this.modeId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'level': level,
        'modeId': modeId,
      };

  factory RecordingItem.fromJson(Map<String, dynamic> json) => RecordingItem(
        id: (json['id'] ?? '').toString(),
        filePath: (json['filePath'] ?? '').toString(),
        createdAt: DateTime.parse((json['createdAt'] ?? DateTime.now().toIso8601String()).toString()),
        level: int.tryParse((json['level'] ?? 1).toString()) ?? 1,
        modeId: (json['modeId'] ?? '1').toString(),
      );
}
