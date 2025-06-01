import 'package:be_with_me_new_new/features/patient/vision/data/models/response/get_helpers_response_model.dart';

abstract class HelperState{}

class HelperInitState extends HelperState{}

class GetHelpersSuccess extends HelperState{
  List<Helper> helpers;
  GetHelpersSuccess({required this.helpers});
}

class GetHelpersLoading extends HelperState{}

class GetHelpersError extends HelperState{
  String message;
  GetHelpersError({required this.message});
}
