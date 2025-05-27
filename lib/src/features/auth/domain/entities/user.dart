import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;

  const User({this.fullName = '', this.email = '', this.phoneNumber = ''});

  @override
  List<Object?> get props => [fullName, email, phoneNumber];
}
