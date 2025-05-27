import 'package:flutter_base/src/features/auth/auth_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    const userJson = {
      'id': 1,
      'full_name': 'Test User',
      'email': 'test@example.com',
      'phone_number': '0123456789',
    };

    test('fromJson should return correct UserModel', () {
      final model = UserModel.fromJson(userJson);

      expect(model.id, 1);
      expect(model.name, 'Test User');
      expect(model.email, 'test@example.com');
      expect(model.phoneNumber, '0123456789');
    });

    test('toJson should return correct map', () {
      final model = UserModel.fromJson(userJson);

      final json = model.toJson();

      // Lưu ý: toJson chỉ có 3 field
      expect(json, {'id': 1, 'name': 'Test User', 'email': 'test@example.com'});
    });

    test('toEntity should return correct User entity', () {
      final model = UserModel.fromJson(userJson);

      final entity = model.toEntity();

      expect(entity.fullName, 'Test User');
      expect(entity.email, 'test@example.com');
      expect(entity.phoneNumber, '0123456789');
    });

    test('Equatable works for UserModel', () {
      final model1 = UserModel.fromJson(userJson);
      final model2 = UserModel.fromJson(userJson);

      expect(model1, equals(model2));
    });
  });
}
