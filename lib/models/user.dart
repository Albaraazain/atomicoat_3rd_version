// lib/models/user.dart
import 'package:uuid/uuid.dart';

enum UserRole {
  operator,
  engineer,
  admin,
}

class User {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String passwordHash;

  User({
    String? id,
    required this.username,
    required this.email,
    required this.role,
    required this.passwordHash,
  }) : id = id ?? Uuid().v4();

  // this method is used to create a new User object with the same values as the current object
  User copyWith({
    String? username,
    String? email,
    UserRole? role,
    String? passwordHash,
  }) {
    return User(
      id: this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.toString(),
      'passwordHash': passwordHash,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: UserRole.values.firstWhere((e) => e.toString() == json['role']),
      passwordHash: json['passwordHash'],
    );
  }
}