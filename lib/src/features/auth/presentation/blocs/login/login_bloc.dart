import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUseCase;
  final IAppStorage appStorage;
  LoginBloc(this.loginUseCase, this.appStorage) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  final emailCtrl = TextEditingController();
  final passworkCtrl = TextEditingController();

  FutureOr<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      email: emailCtrl.text,
      password: passworkCtrl.text,
    );

    await result.fold(
      (failure) {
        emit(LoginInitial());
      },
      (auth) async {
        await appStorage.setValue(AppStorageKey.accessToken, auth.accessToken);
        await appStorage.setValue(
          AppStorageKey.refreshToken,
          auth.refreshToken,
        );

        emit(LoginSuccessful());
      },
    );
  }
}
