// lib/widgets/role_based_access.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_state.dart';
import '../models/user.dart';

class RoleBasedAccess extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;

  const RoleBasedAccess({
    Key? key,
    required this.child,
    required this.allowedRoles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, _) {
        if (userState.currentUser != null &&
            allowedRoles.contains(userState.currentUser!.role)) {
          return child;
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}