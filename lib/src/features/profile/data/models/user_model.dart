import 'package:equatable/equatable.dart';
import 'package:flutter_base/src/core/index.dart';

class UserModel extends Equatable {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? image;

  const UserModel({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] == null ? null : json['id'] as int,
      username: json['username'] == null ? null : json['username'] as String,
      email: json['email'] == null ? null : json['email'] as String,
      firstName: json['firstName'] == null ? null : json['firstName'] as String,
      lastName: json['lastName'] == null ? null : json['lastName'] as String,
      gender: json['gender'] == null ? null : json['gender'] as String,
      image: json['image'] == null ? null : json['image'] as String,
    );
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      image: image,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    gender,
    image,
  ];
}
