import 'package:app_core/app_core.dart';
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
    ).thenAnswer((_) async => authenticate);

    // act
    final result = await usecase(email: email, password: password);

    // assert
    expect(result, authenticate);
    expect(result.accessToken, equals('token123'));
    expect(result.refreshToken, equals('refresh123'));

    verify(() => mockAuthRepository.login(email, password)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test(
    'should throw ServerException when repository throws exception',
    () async {
      // arrange
      final exception = ServerException(
        message: 'Server error',
        statusCode: 500,
      );
      when(
        () => mockAuthRepository.login(email, password),
      ).thenThrow(exception);

      // act & assert
      expect(
        () => usecase(email: email, password: password),
        throwsA(isA<ServerException>()),
      );

      verify(() => mockAuthRepository.login(email, password)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should throw GenericException when repository throws generic error',
    () async {
      // arrange
      final exception = GenericException(message: 'Generic error');
      when(
        () => mockAuthRepository.login(email, password),
      ).thenThrow(exception);

      // act & assert
      expect(
        () => usecase(email: email, password: password),
        throwsA(isA<GenericException>()),
      );

      verify(() => mockAuthRepository.login(email, password)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
