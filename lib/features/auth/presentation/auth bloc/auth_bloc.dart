import 'package:be_with_me_new_new/features/auth/domain/usecases/login_usecase.dart';
import 'package:be_with_me_new_new/features/auth/domain/usecases/register_usecase.dart';
import 'package:be_with_me_new_new/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:be_with_me_new_new/features/auth/domain/usecases/sendcode_usecase.dart';
import 'package:be_with_me_new_new/features/auth/domain/usecases/verifycode_usecase.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_event.dart';
import 'package:be_with_me_new_new/features/auth/presentation/auth%20bloc/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUseCase = LoginUsecase();
  final RegisterUseCase _registerUseCase = RegisterUseCase();
  final SendCodeUsecase _sendCodeUseCase = SendCodeUsecase();
  final VerifyCodeUsecase _verifyCodeUseCase = VerifyCodeUsecase();
  final ResetPasswordUsecase _resetPasswordUseCase = ResetPasswordUsecase();

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SendCodeEvent>(_onSendCode);
    on<VerifyCodeEvent>(_onVerifyCode);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _loginUseCase(event.request);
      emit(LoginSuccess(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _registerUseCase(event.request);
      emit(RegisterSuccess(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendCode(SendCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _sendCodeUseCase(event.request);
      emit(SendCodeSuccess(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyCode(
      VerifyCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _verifyCodeUseCase(event.request);
      emit(VerifyCodeSuccess(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(
      ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _resetPasswordUseCase(event.request);
      emit(ResetPasswordSuccess(result));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
