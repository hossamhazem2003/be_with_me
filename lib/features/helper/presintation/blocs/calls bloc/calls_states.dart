import 'package:be_with_me_new_new/features/helper/data/models/response/call_init_response_model.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/get_patients_response_model.dart';

import '../../../data/models/response/get_calls_history_response_model.dart';

abstract class CallsStates {}

class CallsInitState extends CallsStates {}

class GetCallsHistorySuccess extends CallsStates {
  List<GetCallHistoryResponseModel> callsHistory;
  GetCallsHistorySuccess({required this.callsHistory});
}

class CallsError extends CallsStates {
  String message;
  CallsError({required this.message});
}

class CallsLoading extends CallsStates {}

class InitCallLoadin extends CallsStates {}

class InitCallSuccces extends CallsStates {
  CallInitResponseModel callInitResponseModel;
  InitCallSuccces({required this.callInitResponseModel});
}

class InitCallError extends CallsStates {
  final String message;
  InitCallError({required this.message});
}
