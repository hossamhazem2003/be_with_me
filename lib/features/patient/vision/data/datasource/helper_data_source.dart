import 'dart:convert';
import 'dart:developer';

import 'package:be_with_me_new_new/features/patient/vision/data/models/response/get_helpers_response_model.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/repositories/helper_repository.dart';
import 'package:http/http.dart' as http;

class HelperDataSource extends HelperRepository{
  @override
  Future<List<Helper>> getHelperResponse(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse('https://bewtihme-001-site1.jtempurl.com/api/Helper');

    final request = http.Request('GET', url);
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> decodedJson = json.decode(responseBody);

      final GetHelpersResponse helpersResponse = GetHelpersResponse.fromJson(decodedJson);
      log("${helpersResponse.helpers}");
      return helpersResponse.helpers;
    } else {
      throw Exception('Failed to get helpers: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}