import 'package:bloc/bloc.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_all_patients_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/search_patients_usecase.dart';
import 'patient_events.dart';
import 'patient_states.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetAllPatientsUseCase getAllPatientsUseCase;
  final SearchPatientsUseCase searchPatientsUseCase;

  PatientBloc({
    required this.getAllPatientsUseCase,
    required this.searchPatientsUseCase,
  }) : super(PatientInitial()) {
    on<GetAllPatientsEvent>(_handleGetAllPatients);
    on<SearchPatientsEvent>(_handleSearchPatients);
  }

  Future<void> _handleGetAllPatients(GetAllPatientsEvent event, Emitter<PatientState> emit) async {
    try {
      emit(PatientLoading());
      final patients = await getAllPatientsUseCase(
        token: event.token,
        page: event.page,
        pageSize: event.pageSize,
        status: event.status,
      );
      emit(GetAllPatientsSuccess(patients: patients));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }

  Future<void> _handleSearchPatients(SearchPatientsEvent event, Emitter<PatientState> emit) async {
    try {
      emit(PatientLoading());
      final patients = await searchPatientsUseCase(
        token: event.token,
        search: event.search,
        page: event.page,
        pageSize: event.pageSize,
        status: event.status,
      );
      emit(SearchPatientsSuccess(patients: patients));
    } catch (e) {
      emit(PatientError(message: e.toString()));
    }
  }
}
