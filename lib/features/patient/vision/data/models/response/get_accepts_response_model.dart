class GetAcceptsResponse {
  final String fullName;
  final String profileImageUrl;
  final double rate;
  final int postId;
  final String acceptorId;

  GetAcceptsResponse({
    required this.fullName,
    required this.profileImageUrl,
    required this.rate,
    required this.postId,
    required this.acceptorId,
  });

  factory GetAcceptsResponse.fromJson(Map<String, dynamic> json) {
    return GetAcceptsResponse(
      fullName: json['fullName'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      rate: (json['rate'] as num).toDouble(),
      postId: json['postId'] as int,
      acceptorId: json['acceptorId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'rate': rate,
      'postId': postId,
      'acceptorId': acceptorId,
    };
  }
}
