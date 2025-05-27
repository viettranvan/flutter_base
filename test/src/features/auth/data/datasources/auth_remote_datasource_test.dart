import 'package:dio/dio.dart';
// import 'package:flutter_base/src/features/auth/auth_index.dart';
// import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  // late AuthRemoteDatasource dataSource;
  // late MockDio mockDio;

  // setUp(() {
  //   mockDio = MockDio();
  //   dataSource = AuthRemoteDatasource(mockDio);
  // });

  // group('AuthRemoteDatasource', () {
  //   const email = 'test@example.com';
  //   const password = 'password123';
  //   const path = '/auth/sign-in';

  //   const tAuthenticateModel = AuthenticateModel(
  //     accessToken: 'fake-token',
  //     refreshToken: 'fake-refresh-token',
  //     user: UserModel(
  //       id: 1,
  //       name: 'Test User',
  //       email: email,
  //       phoneNumber: '',
  //     ),
  //   );

  //   final responseData = {
  //     'data': {
  //       'token': 'fake-token',
  //       'user': {
  //         'id': 1,
  //         'name': 'Test User',
  //         'email': email,
  //       },
  //     },
  //   };

  //   test('should return AuthenticateModel when response code is 200', () async {
  //     // arrange
  //     final response = Response(
  //       data: responseData,
  //       statusCode: 200,
  //       requestOptions: RequestOptions(path: path),
  //     );

  //     when(
  //       () => mockDio.post(
  //         any(),
  //         data: any(named: 'data'),
  //       ),
  //     ).thenAnswer((_) async => response);

  //     // act
  //     final result = await dataSource.login(email, password);

  //     // assert
  //     expect(result.accessToken, tAuthenticateModel.accessToken);
  //     expect(result.user?.id, tAuthenticateModel.user?.id);
  //     expect(result.user?.email, tAuthenticateModel.user?.email);

  //     verify(
  //       () => mockDio.post(
  //         path,
  //         data: {'email': email, 'password': password},
  //       ),
  //     ).called(1);
  //   });

  //   test('should throw Exception when response code is not 200', () async {
  //     // arrange
  //     final response = Response(
  //       data: {},
  //       statusCode: 400,
  //       requestOptions: RequestOptions(path: path),
  //     );

  //     when(
  //       () => mockDio.post(
  //         any(),
  //         data: any(named: 'data'),
  //       ),
  //     ).thenAnswer((_) async => response);

  //     // act & assert
  //     expect(
  //       () => dataSource.login(email, password),
  //       throwsA(isA<Exception>()),
  //     );

  //     verify(
  //       () => mockDio.post(
  //         path,
  //         data: {'email': email, 'password': password},
  //       ),
  //     ).called(1);
  //   });

  //   test('should rethrow when DioError occurs', () async {
  //     // arrange
  //     final dioError = DioException(
  //       requestOptions: RequestOptions(path: path),
  //       error: 'Network error',
  //     );

  //     when(
  //       () => mockDio.post(
  //         any(),
  //         data: any(named: 'data'),
  //       ),
  //     ).thenThrow(dioError);

  //     // act & assert
  //     expect(
  //       () => dataSource.login(email, password),
  //       throwsA(isA<DioException>()),
  //     );

  //     verify(
  //       () => mockDio.post(
  //         path,
  //         data: {'email': email, 'password': password},
  //       ),
  //     ).called(1);
  //   });
  // });
}
