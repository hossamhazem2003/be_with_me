import '../../data/models/response/get_patients_response_model.dart';

abstract class PatientRepository {
  Future<GetPatientsResponseModel> getAllPatients({
    required String token,
    int page = 1,
    int pageSize = 5,
    bool status = false,
  });

  Future<GetPatientsResponseModel> searchPatients({
    required String token,
    required String search,
    int page = 1,
    int pageSize = 5,
    bool status = false,
  });
}
