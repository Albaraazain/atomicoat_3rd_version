import 'package:flutter/material.dart';
import '../styles/theme.dart';

class AlertList extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final Function(String) onDismiss;
  final VoidCallback onViewAll;

  const AlertList({
    Key? key,
    required this.alerts,
    required this.onDismiss,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Alerts', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: onViewAll,
                  child: Text('View All'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final alertId = alert['id']?.toString() ?? '';
              return Dismissible(
                key: Key(alertId),
                onDismissed: (_) => onDismiss(alertId),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: _buildSeverityIcon(alert['severity'] ?? ''),
                  title: Text(alert['message'] ?? 'No message', style: TextStyle(color: ALDColors.text)),
                  subtitle: Text(alert['time'] ?? 'No time', style: TextStyle(color: ALDColors.textLight)),
                  trailing: IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Alert Details'),
                            content: Text(alert['details'] ?? 'No details'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityIcon(String severity) {
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