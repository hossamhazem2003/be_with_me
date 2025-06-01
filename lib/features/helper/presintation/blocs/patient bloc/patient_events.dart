abstract class PatientEvent {}

class GetAllPatientsEvent extends PatientEvent {
  final String token;
  final int page;
  final int pageSize;
  final bool status;

  GetAllPatientsEvent({
    required this.token,
    this.page = 1,
    this.pageSize = 5,
    this.status = false,
  });
}

class SearchPatientsEvent extends PatientEvent {
  final String token;
  final String search;
  final int page;
  final int pageSize;
  final bool status;

  SearchPatientsEvent({
    required this.token,
    required this.search,
    this.page = 1,
    this.pageSize = 5,
    this.status = false,
  });
}
