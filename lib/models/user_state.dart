// lib/models/user_state.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:convert';
import 'user.dart';

class UserState extends ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  static const String _storageKey = 'ald_users';
  static const String _currentUserKey = 'current_user';

  User? get currentUser => _currentUser;
  List<User> get users => _users;

  UserState() {
    _loadUsers();
    _loadCurrentUser();
  }

  Future<bool> resetPassword(String username, String newPassword) async {
    final index = _users.indexWhere((user) => user.username == username);
    if (index != -1) {
      final updatedUser = _users[index].copyWith(
        passwordHash: BCrypt.hashpw(newPassword, BCrypt.gensalt()),
      );
      _users[index] = updatedUser;
      await _saveUsers();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> updateUser(User updatedUser) async {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
        await _saveCurrentUser();
      }
      await _saveUsers();
      notifyListeners();
    }
  }

  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? usersJson = prefs.getString(_storageKey);
      if (usersJson != null) {
        final List<dynamic> decodedUsers = jsonDecode(usersJson);
        _users = decodedUsers.map((json) => User.fromJson(json)).toList();
      }

      if (_users.isEmpty) {
        await _createDefaultAdminUser();
      }

      notifyListeners();
    } catch (e) {
      print('Failed to load users: $e');
    }
  }

  Future<void> _createDefaultAdminUser() async {
    final defaultAdmin = User(
      username: 'admin',
      email: 'admin@example.com',
      role: UserRole.admin,
      passwordHash: BCrypt.hashpw('admin123', BCrypt.gensalt()),
    );
    _users.add(defaultAdmin);
    await _saveUsers();
  }

  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedUsers = jsonEncode(_users.map((user) => user.toJson()).toList());
      await prefs.setString(_storageKey, encodedUsers);
    } catch (e) {
      print('Failed to save users: $e');
    }
  }

  Future<void> addUser(User user) async {
    user = user.copyWith(
      passwordHash: BCrypt.hashpw(user.passwordHash, BCrypt.gensalt()),
    );
    _users.add(user);
    await _saveUsers();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final user = _users.firstWhere(
          (user) => user.username == username,
      orElse: () => null as User,
    );

    if (user != null && BCrypt.checkpw(password, user.passwordHash)) {
      _currentUser = user;
      await _saveCurrentUser();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserJson = prefs.getString(_currentUserKey);
      if (currentUserJson != null) {
        _currentUser = User.fromJson(jsonDecode(currentUserJson));
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load current user: $e');
    }
  }

  Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(_currentUserKey, jsonEncode(_currentUser!.toJson()));
      } else {
        await prefs.remove(_currentUserKey);
      }
    } catch (e) {
      print('Failed to save current user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((user) => user.id == id);
    if (_currentUser?.id == id) {
      await logout();
    }
    await _saveUsers();
    notifyListeners();
  }


  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUser();
    notifyListeners();
  }
}