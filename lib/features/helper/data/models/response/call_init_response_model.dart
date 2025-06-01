class CallInitResponseModel {
  final String appId;
  final String uid;
  final String channelName;
  final String message;

  CallInitResponseModel({
    required this.appId,
    required this.uid,
    required this.channelName,
    required this.message,
  });

  factory CallInitResponseModel.fromJson(Map<String, dynamic> json) {
    return CallInitResponseModel(
      appId: json['appId'] as String,
      uid: json['uid'] as String,
      channelName: json['channelName'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'uid': uid,
      'channelName': channelName,
      'message': message,
    };
  }
}
