import 'package:equatable/equatable.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

class AuthenticateModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserModel? user;

  const AuthenticateModel({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthenticateModel.fromJson(Map<String, dynamic> json) {
    return AuthenticateModel(
      accessToken: json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: json['user'] == null ? null : UserModel.fromJson(json['user']),
    );
  }

  /// Convert to domain entity
  Authenticate toEntity() {
    return Authenticate(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user?.toEntity(),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
