import 'package:dartz/dartz.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late AuthRepository repository;
  late MockAuthRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(mockDatasource);
  });

  const email = 'test@example.com';
  const password = 'password123';

  const userModel = UserModel(
    id: 1,
    name: 'Test User',
    email: email,
    phoneNumber: '0123456789',
  );

  const authenticateModel = AuthenticateModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    user: userModel,
  );

  test(
    'should return Right(Authenticate) when datasource returns model',
    () async {
      // arrange
      when(
        () => mockDatasource.login(email, password),
      ).thenAnswer((_) async => authenticateModel);

      // act
      final result = await repository.login(email, password);

      // assert
      expect(result.isRight(), true);
      expect(result, equals(Right(authenticateModel.toEntity())));

      verify(() => mockDatasource.login(email, password)).called(1);
      verifyNoMoreInteractions(mockDatasource);
    },
  );

  test(
    'should return Left(ServerFailure) when datasource throws exception',
    () async {
      // arrange
      when(
        () => mockDatasource.login(email, password),
      ).thenThrow(Exception('Server error'));

      // act
      final result = await repository.login(email, password);

      // assert
      expect(result.isLeft(), true);
      expect(
        result,
        isA<Left<Failure, Authenticate>>().having(
          (l) => l.value,
          'failure',
          isA<ServerFailure>(),
        ),
      );
      expect(
        result.fold((l) => l.message, (_) => ''),
        equals('Exception: Server error'),
      );

      verify(() => mockDatasource.login(email, password)).called(1);
      verifyNoMoreInteractions(mockDatasource);
    },
  );
}
