class CallInitRequestModel {
  final int postId;
  final String acceptorId;

  CallInitRequestModel({
    required this.postId,
    required this.acceptorId,
  });

  factory CallInitRequestModel.fromJson(Map<String, dynamic> json) {
    return CallInitRequestModel(
      postId: json['postId'] as int,
      acceptorId: json['acceptorId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'acceptorId': acceptorId,
    };
  }
}
