import 'package:equatable/equatable.dart';
import 'package:flutter_base/src/features/auth/auth_index.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 1,
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }

  /// Convert to domain entity
  User toEntity() {
    return User(fullName: name, email: email, phoneNumber: phoneNumber);
  }

  @override
  List<Object?> get props => [id, name, email, phoneNumber];
}
