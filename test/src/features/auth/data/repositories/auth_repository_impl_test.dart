import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  // late AuthRepository repository;
  // late MockAuthRemoteDatasource mockDatasource;

  // setUp(() {
  //   mockDatasource = MockAuthRemoteDatasource();
  //   repository = AuthRepositoryImpl(mockDatasource);
  // });

  // const email = 'test@example.com';
  // const password = 'password123';

  // const authenticateModel = AuthenticateModel(
  //   accessToken: 'access-token',
  //   refreshToken: 'refresh-token',
  //   // user: null,
  // );

  // test('should return Authenticate when datasource returns model', () async {
  //   // arrange
  //   when(
  //     () => mockDatasource.login(email, password),
  //   ).thenAnswer((_) async => authenticateModel);

  //   // act
  //   final result = await repository.login(email, password);

  //   // assert
  //   expect(result, equals(authenticateModel.toEntity()));
  //   expect(result.accessToken, equals('access-token'));
  //   expect(result.refreshToken, equals('refresh-token'));
  //   // expect(result.user?.fullName, equals('Test User'));
  //   expect(result.user?.email, equals(email));

  //   verify(() => mockDatasource.login(email, password)).called(1);
  //   verifyNoMoreInteractions(mockDatasource);
  // });

  // test('should throw AppException when datasource throws exception', () async {
  //   // arrange
  //   final exception = ServerException(message: 'Server error', statusCode: 500);
  //   when(() => mockDatasource.login(email, password)).thenThrow(exception);

  //   // act & assert
  //   expect(
  //     () => repository.login(email, password),
  //     throwsA(isA<ServerException>()),
  //   );

  //   verify(() => mockDatasource.login(email, password)).called(1);
  //   verifyNoMoreInteractions(mockDatasource);
  // });

  // test(
  //   'should throw GenericException when datasource throws generic error',
  //   () async {
  //     // arrange
  //     final exception = GenericException(message: 'Generic error');
  //     when(() => mockDatasource.login(email, password)).thenThrow(exception);

  //     // act & assert
  //     expect(
  //       () => repository.login(email, password),
  //       throwsA(isA<GenericException>()),
  //     );

  //     verify(() => mockDatasource.login(email, password)).called(1);
  //     verifyNoMoreInteractions(mockDatasource);
  //   },
  // );
}
