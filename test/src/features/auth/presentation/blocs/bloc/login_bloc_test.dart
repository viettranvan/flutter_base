import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:app_core/app_core.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_base/src/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Usecase
class MockLoginUsecase extends Mock implements LoginUsecase {}

// Mock Storage
class MockAppStorage extends Mock implements IAppStorage {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockAppStorage mockAppStorage;
  late LoginBloc bloc;

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  const tAccessToken = 'access_token';
  const tRefreshToken = 'refresh_token';

  const tAuth = Authenticate(
    accessToken: tAccessToken,
    refreshToken: tRefreshToken,
  );

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockAppStorage = MockAppStorage();

    bloc = LoginBloc(
      mockLoginUsecase,
      mockAppStorage, // inject mock
    );

    bloc.emailCtrl.text = tEmail;
    bloc.passworkCtrl.text = tPassword;
  });

  tearDown(() {
    bloc.close();
  });

  group('SigninBloc', () {
    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginSuccessful] when login succeeds',
      build: () {
        when(
          () => mockLoginUsecase(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => const Right(tAuth));

        when(
          () =>
              mockAppStorage.setValue(AppStorageKey.accessToken, tAccessToken),
        ).thenAnswer((_) async {
          return;
        });

        when(
          () => mockAppStorage.setValue(
            AppStorageKey.refreshToken,
            tRefreshToken,
          ),
        ).thenAnswer((_) async {
          return;
        });

        return bloc;
      },
      act: (bloc) => bloc.add(LoginRequested()),
      expect: () => [LoginLoading(), LoginSuccessful()],
      verify: (_) {
        verify(
          () => mockLoginUsecase(email: tEmail, password: tPassword),
        ).called(1);

        verify(
          () =>
              mockAppStorage.setValue(AppStorageKey.accessToken, tAccessToken),
        ).called(1);

        verify(
          () => mockAppStorage.setValue(
            AppStorageKey.refreshToken,
            tRefreshToken,
          ),
        ).called(1);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginInitial] when login fails',
      build: () {
        when(
          () => mockLoginUsecase(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => Left(ServerFailure('Server error')));

        return bloc;
      },
      act: (bloc) => bloc.add(LoginRequested()),
      expect: () => [LoginLoading(), LoginInitial()],
      verify: (_) {
        verify(
          () => mockLoginUsecase(email: tEmail, password: tPassword),
        ).called(1);
      },
    );
  });
}
