import 'package:be_with_me_new_new/features/helper/data/models/requests/call_init_model_request.dart';

abstract class CallsEvent {}

class GetCallsHistoryEvent extends CallsEvent {}

class InitCallEvent extends CallsEvent {
  CallInitRequestModel callInitRequestModel;
  InitCallEvent({required this.callInitRequestModel});
}
