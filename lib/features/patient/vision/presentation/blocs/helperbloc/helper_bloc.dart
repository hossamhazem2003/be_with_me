

import 'dart:developer';

import 'package:be_with_me_new_new/features/patient/vision/domain/usecases/get_helpers_usecase.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/helperbloc/halper_states.dart';
import 'package:be_with_me_new_new/features/patient/vision/presentation/blocs/helperbloc/helper_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/shared_preferences_manager.dart';

class HelperBloc extends Bloc<HelperEvent, HelperState> {
  final GetHelpersUseCase getHelpersUseCase;


  HelperBloc({
    required this.getHelpersUseCase,
  }) : super(HelperInitState()) {
    on<GetAllHelpers>(_getAllHelpers);
  }

  Future<void> _getAllHelpers(GetAllHelpers event, Emitter<HelperState> emit) async {
    try {
      emit(GetHelpersLoading());
      final token = SharedPreferencesManager.getToken();
      final response = await getHelpersUseCase.call(token!);
      log('${response.length}');
      emit(GetHelpersSuccess(helpers: response));
    } catch (e) {
      emit(GetHelpersError(message: e.toString()));
    }
  }
}


