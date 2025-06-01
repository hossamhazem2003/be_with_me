import 'dart:developer';

import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_calls_history_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/inti_call_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/call_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/calls%20bloc/calls_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallsBloc extends Bloc<CallsEvent, CallsStates> {
  GetCallsHistoryUseCase getCallsHistoryUseCase;
  IntiCallUsecase intiCallUsecase;
  CallsBloc(
      {required this.getCallsHistoryUseCase, required this.intiCallUsecase})
      : super(CallsInitState()) {
    on<GetCallsHistoryEvent>(_getCallsHistory);
    on<InitCallEvent>(_initCall);
  }

  Future<void> _getCallsHistory(
      GetCallsHistoryEvent event, Emitter<CallsStates> state) async {
    try {
      emit(CallsLoading());
      final token = SharedPreferencesManager.getToken();
      final userId = SharedPreferencesManager.getUserId();
      final callsHistory = await getCallsHistoryUseCase.call(token!, userId!);
      emit(GetCallsHistorySuccess(callsHistory: callsHistory));
    } catch (e) {
      log(e.toString());
      emit(CallsError(message: e.toString()));
    }
  }

  Future<void> _initCall(
      InitCallEvent event, Emitter<CallsStates> state) async {
    try {
      emit(InitCallLoadin());
      final token = SharedPreferencesManager.getToken();
      final callInitResponseModel =
          await intiCallUsecase.call(token!, event.callInitRequestModel);
      emit(InitCallSuccces(callInitResponseModel: callInitResponseModel));
    } catch (e) {
      emit(InitCallError(message: e.toString()));
    }
  }
}
