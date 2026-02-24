class ParentProfile {
  final String parentName;
  final String phone;
  final String childName;
  final String notes;

  ParentProfile({
    required this.parentName,
    required this.phone,
    required this.childName,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'parentName': parentName,
        'phone': phone,
        'childName': childName,
        'notes': notes,
      };

  factory ParentProfile.fromJson(Map<String, dynamic> json) => ParentProfile(
        parentName: (json['parentName'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        childName: (json['childName'] ?? '').toString(),
        notes: (json['notes'] ?? '').toString(),
      );
}
