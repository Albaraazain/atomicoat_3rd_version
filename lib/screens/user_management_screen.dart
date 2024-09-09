// lib/screens/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import '../models/user.dart';
import 'registration_screen.dart';
import 'edit_user_screen.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrationScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserState>(
        builder: (context, userState, child) {
          return ListView.builder(
            itemCount: userState.users.length,
            itemBuilder: (context, index) {
              final user = userState.users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text(user.email),
                trailing: Text(user.role.toString().split('.').last),
                onTap: () {
                  _showUserActions(context, user, userState);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showUserActions(BuildContext context, User user, UserState userState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User Actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit User'),
                onTap: () {
                  Navigator.pop(context);
                  _editUser(context, user);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete User'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteUser(context, user, userState);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editUser(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    );
  }

  void _deleteUser(BuildContext context, User user, UserState userState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete ${user.username}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                userState.deleteUser(user.id);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}