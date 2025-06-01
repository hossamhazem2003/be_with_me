import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/get_profile_data_usecase.dart';
import 'package:be_with_me_new_new/features/helper/domain/usecases/update_profile_usecase.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/profile%20bloc/profile_events.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/profile%20bloc/profile_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entites/helper_entity.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileDataUsecase getProfileUseCase;
  final UpdateProfileUsecase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<GetProfileDataEvent>(_handleGetProfile);
    on<UpdateProfileEvent>(_handleUpdateProfile);
  }

  Future<void> _handleGetProfile(
      GetProfileDataEvent event, Emitter<ProfileState> emit) async {
    try {
      final token = SharedPreferencesManager.getToken();
      emit(ProfileLoading());
      final profile = await getProfileUseCase(token: token!);
      emit(GetProfileSuccess(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _handleUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      final currentState = state;
      HelperEntity? currentProfile;

      if (currentState is GetProfileSuccess) {
        currentProfile = currentState.profile;
      } else if (currentState is UpdateProfileSuccess) {
        currentProfile = currentState.profile;
      }

      if (currentProfile != null) {
        emit(UpdateProfileLoading(currentProfile: currentProfile));

        final updatedProfile = await updateProfileUseCase(
          token: SharedPreferencesManager.getToken()!,
          fullName: event.fullName,
          gender: event.gender,
          languagePreference: event.languagePreference,
          profileImage: event.profileImage,
        );

        final token = SharedPreferencesManager.getToken();
        final helperProf = await getProfileUseCase.call(token: token!);

        HelperEntity helperEntity = HelperEntity(
            fullName: event.fullName,
            gender: event.gender,
            dateOfBirth: helperProf.dateOfBirth,
            email: helperProf.email,
            languagePreference: event.languagePreference,
            rate: helperProf.rate,
            profileImageUrl: event.profileImage);

        emit(UpdateProfileSuccess(
          profile: helperEntity,
          fullName: event.fullName,
          gender: event.gender,
          languagePreference: event.languagePreference,
          profileImage: event.profileImage,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
