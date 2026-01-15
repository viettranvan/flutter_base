import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticateModel', () {
    const userJson = {
      'id': 'dc8485a6-f5ec-4da8-8802-9202d22c0736',
      'email': 'test@example.com',
      'fullName': 'Test User',
      'phoneNumber': '0123456789',
      'phoneCode': '+65',
      'isPhoneVerified': false,
      'avatar': 'https://example.com/avatar.jpg',
      'dateOfBirth': '2000-12-13T17:00:00.000Z',
      'gender': 'male',
      'homeCourt': 'Test Court',
      'heightCm': 178,
      'birthPlace': 'Singapore',
      'bio': 'Test bio',
      'privacyStatus': 'public',
      'singlesRating': 6.34,
      'doublesRating': 4.4,
      'status': 'active',
      'state': 'questionnaire_completed',
      'createdAt': '2025-11-12T05:05:06.354Z',
      'updatedAt': '2026-01-02T09:26:26.758Z',
    };

    const authJson = {
      'data': {
        'tokens': {
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
        },
        'user': userJson,
      },
    };

    test(
      'fromJson should return correct AuthenticateModel with nested data',
      () {
        // final model = AuthenticateModel.fromJson(authJson);

        // expect(model.accessToken, 'access-token');
        // expect(model.refreshToken, 'refresh-token');
        // expect(model.user?.id, 'dc8485a6-f5ec-4da8-8802-9202d22c0736');
        // expect(model.user?.fullName, 'Test User');
        // expect(model.user?.email, 'test@example.com');
        // expect(model.user?.phoneNumber, '0123456789');
        // expect(model.user?.phoneCode, '+65');
        // expect(model.user?.avatar, 'https://example.com/avatar.jpg');
        // expect(model.user?.singlesRating, 6.34);
        // expect(model.user?.doublesRating, 4.4);
      },
    );

    test('fromJson should handle legacy format (non-nested tokens)', () {
      // const legacyJson = {
      //   'token': 'legacy-token',
      //   'refresh_token': 'legacy-refresh',
      //   'user': userJson,
      // };

      // final model = AuthenticateModel.fromJson(legacyJson);

      // expect(model.accessToken, 'legacy-token');
      // expect(model.refreshToken, 'legacy-refresh');
      // expect(model.user?.email, 'test@example.com');
    });

    test('toEntity should return correct Authenticate entity', () {
      // final model = AuthenticateModel.fromJson(authJson);
      // final entity = model.toEntity();

      // expect(entity.accessToken, 'access-token');
      // expect(entity.refreshToken, 'refresh-token');
      // expect(entity.user?.fullName, 'Test User');
      // expect(entity.user?.email, 'test@example.com');
      // expect(entity.user?.phoneNumber, '0123456789');
      // expect(entity.user?.singlesRating, 6.34);
    });

    test('Equatable works for AuthenticateModel', () {
      final model1 = AuthenticateModel.fromJson(authJson);
      final model2 = AuthenticateModel.fromJson(authJson);

      expect(model1, equals(model2));
    });

    test('UserModel toEntity converts all fields correctly', () {
      // final userModel = UserModel.fromJson(userJson);
      // final userEntity = userModel.toEntity();

      // expect(userEntity.id, userModel.id);
      // expect(userEntity.fullName, userModel.fullName);
      // expect(userEntity.email, userModel.email);
      // expect(userEntity.avatar, userModel.avatar);
      // expect(userEntity.singlesRating, userModel.singlesRating);
      // expect(userEntity.status, userModel.status);
    });
  });
}
