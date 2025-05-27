import 'package:dartz/dartz.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUsecase(mockAuthRepository);
  });

  const email = 'test@example.com';
  const password = 'password123';
  const authenticate = Authenticate(
    accessToken: 'token123',
    refreshToken: 'refresh123',
  );

  test('should return Authenticate when repository returns success', () async {
    // arrange
    when(
      () => mockAuthRepository.login(email, password),
    ).thenAnswer((_) async => const Right(authenticate));

    // act
    final result = await usecase(email: email, password: password);

    // assert
    expect(result, const Right(authenticate));
    verify(() => mockAuthRepository.login(email, password)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when repository returns failure', () async {
    // arrange
    final failure = ServerFailure('Server error');
    when(
      () => mockAuthRepository.login(email, password),
    ).thenAnswer((_) async => Left(failure));

    // act
    final result = await usecase(email: email, password: password);

    // assert
    expect(result, Left(failure));
    verify(() => mockAuthRepository.login(email, password)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
