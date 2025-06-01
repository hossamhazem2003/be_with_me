class Patient {
  final String id;
  final String fullName;
  final int age;
  final int helpCount;
  final String? needsDescription;
  final String profileImageUrl;

  Patient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.helpCount,
    required this.needsDescription,
    required this.profileImageUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['fullName'],
      age: json['age'],
      helpCount: json['helpCount'],
      needsDescription: json['needsDescription'] ?? "",
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'helpCount': helpCount,
      'needsDescription': needsDescription,
      'profileImageUrl': profileImageUrl,
    };
  }
}