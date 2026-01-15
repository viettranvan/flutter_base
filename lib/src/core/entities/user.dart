import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? image;

  const User({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.image,
  });

  String get fullName {
    final fName = firstName ?? '';
    final lName = lastName ?? '';
    if (fName.isEmpty && lName.isEmpty) {
      return 'No Name';
    }
    return '$fName $lName'.trim();
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
