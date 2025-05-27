import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticateModel', () {
    const userJson = {
      'id': 1,
      'full_name': 'Test User',
      'email': 'test@example.com',
      'phone_number': '0123456789',
    };

    const authJson = {
      'token': 'access-token',
      'refresh_token': 'refresh-token',
      'user': userJson,
    };

    test('fromJson should return correct AuthenticateModel', () {
      final model = AuthenticateModel.fromJson(authJson);

      expect(model.accessToken, 'access-token');
      expect(model.refreshToken, 'refresh-token');
      expect(model.user?.id, 1);
      expect(model.user?.name, 'Test User');
      expect(model.user?.email, 'test@example.com');
      expect(model.user?.phoneNumber, '0123456789');
    });

    test('toEntity should return correct Authenticate entity', () {
      final model = AuthenticateModel.fromJson(authJson);
      final entity = model.toEntity();

      expect(entity.accessToken, 'access-token');
      expect(entity.refreshToken, 'refresh-token');
      expect(entity.user?.fullName, 'Test User');
      expect(entity.user?.email, 'test@example.com');
      expect(entity.user?.phoneNumber, '0123456789');
    });

    test('Equatable works for UserModel', () {
      final model1 = AuthenticateModel.fromJson(userJson);
      final model2 = AuthenticateModel.fromJson(userJson);

      expect(model1, equals(model2));
    });
  });
}
