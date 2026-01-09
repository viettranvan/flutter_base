import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.website,
    required super.company,
    required super.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      company:
          (json['company'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      address: _parseAddress(json['address'] as Map<String, dynamic>? ?? {}),
    );
  }

  static String _parseAddress(Map<String, dynamic> addressMap) {
    final street = addressMap['street'] as String? ?? '';
    final city = addressMap['city'] as String? ?? '';
    return '$street, $city'.replaceAll(RegExp(r', $'), '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'website': website,
      'company': company,
      'address': address,
    };
  }
}
