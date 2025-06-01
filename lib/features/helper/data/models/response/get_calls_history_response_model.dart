class GetCallHistoryResponseModel {
  final int id;
  final int postId;
  final CallUser caller;
  final CallUser callee;
  final DateTime startTime;
  final DateTime? endTime;
  final double duration;

  GetCallHistoryResponseModel({
    required this.id,
    required this.postId,
    required this.caller,
    required this.callee,
    required this.startTime,
    this.endTime,
    required this.duration,
  });

  factory GetCallHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return GetCallHistoryResponseModel(
      id: json['id'] as int,
      postId: json['postId'] as int,
      caller: CallUser.fromJson(json['caller'] as Map<String, dynamic>),
      callee: CallUser.fromJson(json['callee'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime:
          json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      duration: (json['duration'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'caller': caller.toJson(),
      'callee': callee.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
    };
  }
}

class CallUser {
  final String id;
  final String fullName;
  final String pictureUrl;

  CallUser({
    required this.id,
    required this.fullName,
    required this.pictureUrl,
  });

  factory CallUser.fromJson(Map<String, dynamic> json) {
    return CallUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      pictureUrl: json['pictureUrl'] as String,
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
