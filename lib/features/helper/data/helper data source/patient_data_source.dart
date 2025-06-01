import 'dart:convert';
import 'dart:developer';

import 'package:be_with_me_new_new/features/helper/domain/repositories/patient_repository.dart';
import 'package:http/http.dart' as http;

import '../models/response/get_patients_response_model.dart';

class PatientDataSource extends PatientRepository {
  final String baseUrl = 'https://bewtihme-001-site1.jtempurl.com/api';

  @override
  Future<GetPatientsResponseModel> getAllPatients({
    required String token,
    int page = 1,
    int pageSize = 5,
    bool status = false,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/Patient?page=$page&pageSize=$pageSize&Status=$status',
      );

      var headers = {
        'Authorization': 'Bearer $token',
        'Host': 'bewtihme-001-site1.jtempurl.com',
        'Connection': 'keep-alive',
      };

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);

      final response = await request.send();
      final body = await response.stream.bytesToString();

      log(body);


      if (response.statusCode == 200) {
        final jsonData = jsonDecode(body);
        return GetPatientsResponseModel.fromJson(jsonData);
      } else {
        throw Exception('فشل تحميل البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في جلب البيانات: $e');
    }
  }

  @override
  Future<GetPatientsResponseModel> searchPatients({
    required String token,
    required String search,
    int page = 1,
    int pageSize = 5,
    bool status = false,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/Patient?search=$search&page=$page&pageSize=$pageSize&Status=$status',
      );

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
        return GetPatientsResponseModel.fromJson(jsonData);
      } else {
        throw Exception('فشل في البحث عن المرضى: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ أثناء البحث: $e');
    }
  }
}
