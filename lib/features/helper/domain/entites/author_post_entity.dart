class AuthorModel {
  final String id;
  final String fullName;
  final String pictureUrl;

  AuthorModel({
    required this.id,
    required this.fullName,
    required this.pictureUrl,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'],
      fullName: json['fullName'],
      pictureUrl: json['pictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'pictureUrl': pictureUrl,
    };
  }
}
