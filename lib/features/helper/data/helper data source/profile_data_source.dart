import 'dart:convert';

import 'package:be_with_me_new_new/features/helper/domain/entites/helper_entity.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/profile_repository.dart';
import 'package:http/http.dart' as http;

class ProfileDataSource extends ProfileRepository {
  final String baseUrl = 'https://bewtihme-001-site1.jtempurl.com/api';
  @override
  Future<HelperEntity> getProfile({required String token}) async {
    try {
      final uri = Uri.parse('$baseUrl/Profile');

      var headers = {
        'Authorization': 'Bearer $token',
        'Host': 'bewtihme-001-site1.jtempurl.com',
        'Connection': 'keep-alive',
      };

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(body);
        return HelperEntity.fromJson(jsonData);
      } else {
        throw Exception('فشل في جلب البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ أثناء جلب البيانات: $e');
    }
  }

  @override
  Future<void> updateProfile({
    required String token,
    required String fullName,
    required String gender,
    required String languagePreference,
    required String profileImage, // يمكن أن يكون مسار ملف أو قيمة فارغة
  }) async {
    final uri = Uri.parse('$baseUrl/Profile');

    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final request = http.MultipartRequest('PUT', uri);
    request.fields.addAll({
      'FullName': fullName,
      'Gender': gender,
      'LanguagePreference': languagePreference,
      'ProfileImage': profileImage, // ضع "" إذا لم يتم رفع صورة
    });

    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
