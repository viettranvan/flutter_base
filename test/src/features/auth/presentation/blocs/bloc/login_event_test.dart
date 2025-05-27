import 'package:flutter_base/src/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginEvent', () {
    test('LoginRequested props is empty', () {
      expect(LoginRequested().props, []);
    });
  });
}
