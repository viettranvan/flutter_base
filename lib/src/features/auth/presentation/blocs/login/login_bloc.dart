import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/error_handler.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUseCase;
  final IAppStorage appStorage;

  LoginBloc(this.loginUseCase, this.appStorage) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  final emailCtrl = TextEditingController(text: 'emilys');
  final passworkCtrl = TextEditingController(text: 'emilyspass');

  FutureOr<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final auth = await loginUseCase(
        email: emailCtrl.text,
        password: passworkCtrl.text,
      );

      await appStorage.setValue(AppStorageKey.accessToken, auth.accessToken);
      await appStorage.setValue(AppStorageKey.refreshToken, auth.refreshToken);

      emit(LoginSuccessful());
    } on AppException catch (e) {
      appLogger.e('Login Error: ${e.message}');
      GlobalErrorHandler.handle(e);
      emit(LoginInitial());
    } catch (e) {
      appLogger.e('Unexpected Error', error: e);
      emit(LoginInitial());
    }
  }
}
