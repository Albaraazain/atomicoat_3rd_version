// lib/widgets/alert_status_bar.dart

import 'package:flutter/material.dart';
import '../models/reactor_state.dart';

class AlertStatusBar extends StatelessWidget {
  final ReactorState reactorState;

  AlertStatusBar({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: _getStatusColor(reactorState.systemStatus),
      child: Text(
        'System Status: ${reactorState.systemStatus}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'warning':
        return Colors.yellow;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}