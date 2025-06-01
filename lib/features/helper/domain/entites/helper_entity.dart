class HelperEntity {
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final String email;
  final String languagePreference;
  final double rate;
  final String profileImageUrl;

  HelperEntity({
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.languagePreference,
    required this.rate,
    required this.profileImageUrl,
  });

  factory HelperEntity.fromJson(Map<String, dynamic> json) {
    return HelperEntity(
      fullName: json['fullName'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      email: json['email'] as String,
      languagePreference: json['languagePreference'] as String,
      rate: (json['rate'] ?? 0 as num).toDouble(),
      profileImageUrl: json['profileImageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'email': email,
      'languagePreference': languagePreference,
      'rate': rate,
      'profileImageUrl': profileImageUrl,
    };
  }
}
