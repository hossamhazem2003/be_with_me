import 'package:be_with_me_new_new/features/helper/data/models/requests/call_init_model_request.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/call_init_response_model.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_calls_history_response_model.dart';

abstract class CallsRepository {
  Future<List<GetCallHistoryResponseModel>> getCallsHistory(
      String token, String userId);
  Future<CallInitResponseModel> initCall(
      String token, CallInitRequestModel callInitRequestModel);
}
