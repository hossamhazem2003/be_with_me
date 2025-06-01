class GetHelpersResponse {
  final List<Helper> helpers;
  final int totalHelpers;
  final int currentPage;
  final int pageSize;

  GetHelpersResponse({
    required this.helpers,
    required this.totalHelpers,
    required this.currentPage,
    required this.pageSize,
  });

  factory GetHelpersResponse.fromJson(Map<String, dynamic> json) {
    return GetHelpersResponse(
      helpers: (json['helpers'] as List<dynamic>)
          .map((e) => Helper.fromJson(e))
          .toList(),
      totalHelpers: json['totalHelpers'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'helpers': helpers.map((e) => e.toJson()).toList(),
      'totalHelpers': totalHelpers,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }
}

class Helper {
  final String id;
  final String fullName;
  final int age;
  final double rate;
  final String profileImageUrl;

  Helper({
    required this.id,
    required this.fullName,
    required this.age,
    required this.rate,
    required this.profileImageUrl,
  });

  factory Helper.fromJson(Map<String, dynamic> json) {
    return Helper(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      age: json['age'] as int,
      rate: (json['rate'] as num).toDouble(),
      profileImageUrl: (json['profileImageUrl'] as String).replaceAll("\\", "/"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'rate': rate,
      'profileImageUrl': profileImageUrl,
    };
  }
}
