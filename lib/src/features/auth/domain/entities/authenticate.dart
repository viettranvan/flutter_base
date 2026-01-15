import 'package:equatable/equatable.dart';
import 'package:flutter_base/src/core/index.dart';

class Authenticate extends Equatable {
  final String accessToken;
  final String refreshToken;
  final User? user;

  const Authenticate({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
