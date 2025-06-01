import 'dart:convert';
import 'dart:developer';

import 'package:be_with_me_new_new/features/helper/data/models/requests/call_init_model_request.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/call_init_response_model.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_calls_history_response_model.dart';
import 'package:http/http.dart' as http;

import '../../domain/repositories/calls_repository.dart';

class CallsDataSource extends CallsRepository {
  @override
  Future<List<GetCallHistoryResponseModel>> getCallsHistory(
      String token, String userId) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final url = Uri.parse(
        'https://bewtihme-001-site1.jtempurl.com/api/Calls/$userId/call-history');

    final request = http.Request('GET', url);
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final List<dynamic> jsonList = json.decode(responseBody);
      final List<GetCallHistoryResponseModel> historyList = jsonList
          .map((item) => GetCallHistoryResponseModel.fromJson(item))
          .toList();
      log(historyList.toString());
      return historyList;
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  @override
  Future<CallInitResponseModel> initCall(
      String token, CallInitRequestModel callInitRequestModel) async {
    final uri = Uri.parse(
        'https://bewtihme-001-site1.jtempurl.com/api/Calls/initiate-call');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Host': 'bewtihme-001-site1.jtempurl.com',
      'Connection': 'keep-alive',
    };

    final body = jsonEncode(callInitRequestModel.toJson());

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return CallInitResponseModel.fromJson(responseData);
    } else {
      throw Exception('Call initiation failed: ${response.reasonPhrase}');
    }
  }
}
