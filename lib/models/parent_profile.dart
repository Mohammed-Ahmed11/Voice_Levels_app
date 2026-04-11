class ParentProfile {
  final String id;
  final String parentName;
  final String phone;
  final String childName;
  final String notes;

  const ParentProfile({
    required this.id,
    required this.parentName,
    required this.phone,
    required this.childName,
    required this.notes,
  });

  String get displayName {
    final name = childName.trim().isNotEmpty ? childName.trim() : parentName.trim();
    return name.isEmpty ? 'Unnamed Profile' : name;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentName': parentName,
        'phone': phone,
        'childName': childName,
        'notes': notes,
      };

  factory ParentProfile.fromJson(Map<String, dynamic> json) => ParentProfile(
        id: (json['id'] ?? '').toString(),
        parentName: (json['parentName'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        childName: (json['childName'] ?? '').toString(),
        notes: (json['notes'] ?? '').toString(),
      );
}