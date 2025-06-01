class ReactionsEntity {
  final String fullName;
  final String profileImageUrl;
  final double rate;

  ReactionsEntity({
    required this.fullName,
    required this.profileImageUrl,
    required this.rate,
  });

  factory ReactionsEntity.fromJson(Map<String, dynamic> json) {
    return ReactionsEntity(
      fullName: json['fullName'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'rate': rate,
    };
  }

  static List<ReactionsEntity> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ReactionsEntity.fromJson(json)).toList();
  }
}
