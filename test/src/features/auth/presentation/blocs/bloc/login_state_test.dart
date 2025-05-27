import 'package:flutter_base/src/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginState', () {
    test('LoginInitial props is empty', () {
      expect(LoginInitial().props, []);
    });
    test('LoginLoading props is empty', () {
      expect(LoginLoading().props, []);
    });
    test('LoginSuccessful props is empty', () {
      expect(LoginSuccessful().props, []);
    });
  });
}
