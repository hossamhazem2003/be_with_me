import 'package:be_with_me_new_new/features/helper/data/models/response/get_patients_response_model.dart';

abstract class PatientState {}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class GetAllPatientsSuccess extends PatientState {
  final GetPatientsResponseModel patients;

  GetAllPatientsSuccess({required this.patients});
}

class SearchPatientsSuccess extends PatientState {
  final GetPatientsResponseModel patients;

  SearchPatientsSuccess({required this.patients});
}

class PatientError extends PatientState {
  final String message;

  PatientError({required this.message});
}
