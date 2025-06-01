import 'package:be_with_me_new_new/features/helper/domain/entites/patient_entity.dart';

class GetPatientsResponseModel {
  final List<Patient> patients;
  final int totalPatients;
  final int currentPage;
  final int pageSize;

  GetPatientsResponseModel({
    required this.patients,
    required this.totalPatients,
    required this.currentPage,
    required this.pageSize,
  });

  factory GetPatientsResponseModel.fromJson(Map<String, dynamic> json) {
    return GetPatientsResponseModel(
      patients: List<Patient>.from(
        json['patients'].map((x) => Patient.fromJson(x)),
      ),
      totalPatients: json['totalPatients'],
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patients': patients.map((x) => x.toJson()).toList(),
      'totalPatients': totalPatients,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }
}

