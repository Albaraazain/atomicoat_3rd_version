import 'package:flutter/material.dart';
import '../styles/theme.dart';

class AlertCard extends StatelessWidget {
  final String message;
  final String time;
  final String severity;

  const AlertCard({
    Key? key,
    required this.message,
    required this.time,
    required this.severity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _buildSeverityIcon(),
        title: Text(message, style: TextStyle(color: ALDColors.text)),
        subtitle: Text(time, style: TextStyle(color: ALDColors.textLight)),
      ),
    );
  }

  Widget _buildSeverityIcon() {
    IconData iconData;
    Color iconColor;

    switch (severity.toLowerCase()) {
      case 'high':
        iconData = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case 'medium':
        iconData = Icons.warning_amber_outlined;
        iconColor = Colors.orange;
        break;
      case 'low':
        iconData = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = ALDColors.textLight;
    }

    return Icon(iconData, color: iconColor);
  }
}