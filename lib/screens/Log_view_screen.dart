// lib/screens/log_view_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_state.dart';

class LogViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Process Log'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Clear Log'),
                  content: Text('Are you sure you want to clear the log?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Clear'),
                      onPressed: () {
                        Provider.of<DashboardState>(context, listen: false).clearLog();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DashboardState>(
        builder: (context, dashboardState, child) {
          return ListView.builder(
            itemCount: dashboardState.logEntries.length,
            itemBuilder: (context, index) {
              final logEntry = dashboardState.logEntries[dashboardState.logEntries.length - 1 - index];
              return ListTile(
                title: Text(logEntry.description),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(logEntry.timestamp)),
                leading: Icon(Icons.history),
              );
            },
          );
        },
      ),
    );
  }
}