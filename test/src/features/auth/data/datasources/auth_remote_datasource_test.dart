import 'package:app_core/app_core.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  // late AuthRemoteDatasource dataSource;
  // late MockHttpClient mockHttpClient;

  // setUp(() {
  //   mockHttpClient = MockHttpClient();
  //   dataSource = AuthRemoteDatasource(mockHttpClient);
  // });

  // group('AuthRemoteDatasource', () {
  //   const email = 'ryuk@vinova.com.sg';
  //   const password = 'password123';
  //   const path = '/auth/signin';

  //   // final responseData = {
  //   //   'success': true,
  //   //   'timestamp': '2026-01-15T03:24:50.094Z',
  //   //   'requestId': '069cec73-af09-438e-bc78-5c94a07dd45f',
  //   //   'duration': 324,
  //   //   'data': {
  //   //     'tokens': {
  //   //       'accessToken':
  //   //           'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImRjODQ4NWE2LWY1ZWMtNGRhOC04ODAyLTkyMDJkMjJjMDczNiIsImVtYWlsIjoicnl1a0B2aW5vdmEuY29tLnNnIiwicm9sZSI6InVzZXIiLCJpYXQiOjE3Njg0NDc0OTAsImV4cCI6MTc2ODUzMzg5MCwiaXNzIjoidGllYnJlYWsifQ.mkKiVs5aQl2xJTh7qUqz7ojg5c5nKO22UkZYW3vg9Qc',
  //   //       'refreshToken':
  //   //           'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkYzg0ODVhNi1mNWVjLTRkYTgtODgwMi05MjAyZDIyYzA3MzYiLCJqdGkiOiJkNTllM2FiMC1mNDgxLTRmMTMtOTcwMS03M2I0YzBiZGQ4MGUiLCJpYXQiOjE3Njg0NDc0OTAsImV4cCI6MTc2OTA1MjI5MCwiaXNzIjoidGllYnJlYWsifQ.Aalt9Z5m_4lkH489jOMBx1CIx4WodY0vuRyD7Y4edmw',
  //   //       'jti': 'd59e3ab0-f481-4f13-9701-73b4c0bdd80e',
  //   //     },
  //   //     'user': {
  //   //       'id': 'dc8485a6-f5ec-4da8-8802-9202d22c0736',
  //   //       'email': email,
  //   //       'phoneCode': '+65',
  //   //       'phoneNumber': '123123123117',
  //   //       'isPhoneVerified': false,
  //   //       'avatar':
  //   //           'https://tiebreak-dev.s3.ap-southeast-1.amazonaws.com/uploads/image/1765792123789-1DCEA32E-C104-4A46-8199-45ABCA6820CB.png',
  //   //       'fullName': 'Ryuk Tran',
  //   //       'dateOfBirth': '2000-12-13T17:00:00.000Z',
  //   //       'gender': 'male',
  //   //       'homeCourt': 'Vinova Tennis',
  //   //       'heightCm': 178,
  //   //       'birthPlace': 'Singapore',
  //   //       'bio': 'Test bio',
  //   //       'privacyStatus': 'public',
  //   //       'singlesRating': 6.34,
  //   //       'doublesRating': 4.4,
  //   //       'status': 'active',
  //   //       'state': 'questionnaire_completed',
  //   //       'createdAt': '2025-11-12T05:05:06.354Z',
  //   //       'updatedAt': '2026-01-02T09:26:26.758Z',
  //   //       'deletedAt': null,
  //   //     },
  //   //   },
  //   // };

  //   test('should return AuthenticateModel when response code is 200', () async {
  //     // // arrange
  //     // final response = Response(
  //     //   data: responseData,
  //     //   statusCode: 200,
  //     //   requestOptions: RequestOptions(path: path),
  //     // );

  //     // when(
  //     //   () => mockHttpClient.post(any(), data: any(named: 'data')),
  //     // ).thenAnswer((_) async => response);

  //     // // act
  //     // final result = await dataSource.login(email, password);

  //     // // assert
  //     // expect(result.user?.id, 'dc8485a6-f5ec-4da8-8802-9202d22c0736');
  //     // expect(result.user?.email, email);
  //     // expect(result.user?.fullName, 'Ryuk Tran');
  //     // expect(result.user?.singlesRating, 6.34);
  //     // expect(result.user?.status, 'active');

  //     // verify(
  //     //   () => mockHttpClient.post(
  //     //     path,
  //     //     data: {'email': email, 'password': password},
  //     //   ),
  //     // ).called(1);
  //   });

  //   test(
  //     'should throw ServerException when response code is not 2xx',
  //     () async {
  //       // arrange
  //       final response = Response(
  //         data: {'error': 'Unauthorized'},
  //         statusCode: 401,
  //         requestOptions: RequestOptions(path: path),
  //       );

  //       when(
  //         () => mockHttpClient.post(any(), data: any(named: 'data')),
  //       ).thenAnswer((_) async => response);

  //       // act & assert
  //       expect(
  //         () => dataSource.login(email, password),
  //         throwsA(isA<ServerException>()),
  //       );

  //       verify(
  //         () => mockHttpClient.post(
  //           path,
  //           data: {'email': email, 'password': password},
  //         ),
  //       ).called(1);
  //     },
  //   );

  //   test('should throw GenericException when JSON format is invalid', () async {
  //     // arrange
  //     final response = Response(
  //       data: {'data': 'invalid_format'},
  //       statusCode: 200,
  //       requestOptions: RequestOptions(path: path),
  //     );

  //     when(
  //       () => mockHttpClient.post(any(), data: any(named: 'data')),
  //     ).thenAnswer((_) async => response);

  //     // act & assert
  //     expect(
  //       () => dataSource.login(email, password),
  //       throwsA(isA<GenericException>()),
  //     );
  //   });

  //   test('should throw GenericException when http request fails', () async {
  //     // arrange
  //     when(
  //       () => mockHttpClient.post(any(), data: any(named: 'data')),
  //     ).thenThrow(
  //       DioException(
  //         requestOptions: RequestOptions(path: path),
  //         type: DioExceptionType.connectionTimeout,
  //       ),
  //     );

  //     // act & assert
  //     expect(
  //       () => dataSource.login(email, password),
  //       throwsA(isA<GenericException>()),
  //     );
  //   });
  // });
}
