// lib/screens/alarm_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_state.dart';
import '../models/alarm.dart';

class AlarmManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAlarmDialog(context),
          ),
        ],
      ),
      body: Consumer<DashboardState>(
        builder: (context, dashboardState, child) {
          return ListView.builder(
            itemCount: dashboardState.alarms.length,
            itemBuilder: (context, index) {
              final alarm = dashboardState.alarms[index];
              return ListTile(
                title: Text(alarm.name),
                subtitle: Text('${alarm.type.toString().split('.').last} ${alarm.condition.toString().split('.').last} ${alarm.threshold}'),
                trailing: Switch(
                  value: alarm.isActive,
                  onChanged: (bool value) {
                    final updatedAlarm = Alarm(
                      id: alarm.id,
                      name: alarm.name,
                      type: alarm.type,
                      condition: alarm.condition,
                      threshold: alarm.threshold,
                      isActive: value,
                    );
                    dashboardState.updateAlarm(updatedAlarm);
                  },
                ),
                onTap: () => _showAlarmDialog(context, alarm: alarm),
              );
            },
          );
        },
      ),
    );
  }

  void _showAlarmDialog(BuildContext context, {Alarm? alarm}) {
    final nameController = TextEditingController(text: alarm?.name ?? '');
    final thresholdController = TextEditingController(text: alarm?.threshold.toString() ?? '');
    var type = alarm?.type ?? AlarmType.temperature;
    var condition = alarm?.condition ?? AlarmCondition.greaterThan;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(alarm == null ? 'Add Alarm' : 'Edit Alarm'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Alarm Name'),
                    ),
                    DropdownButton<AlarmType>(
                      value: type,
                      onChanged: (AlarmType? newValue) {
                        setState(() {
                          type = newValue!;
                        });
                      },
                      items: AlarmType.values.map((AlarmType type) {
                        return DropdownMenuItem<AlarmType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    DropdownButton<AlarmCondition>(
                      value: condition,
                      onChanged: (AlarmCondition? newValue) {
                        setState(() {
                          condition = newValue!;
                        });
                      },
                      items: AlarmCondition.values.map((AlarmCondition condition) {
                        return DropdownMenuItem<AlarmCondition>(
                          value: condition,
                          child: Text(condition.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    TextField(
                      controller: thresholdController,
                      decoration: InputDecoration(labelText: 'Threshold'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(alarm == null ? 'Add' : 'Update'),
                  onPressed: () {
                    final dashboardState = Provider.of<DashboardState>(context, listen: false);
                    final newAlarm = Alarm(
                      id: alarm?.id,
                      name: nameController.text,
                      type: type,
                      condition: condition,
                      threshold: double.parse(thresholdController.text),
                    );
                    if (alarm == null) {
                      dashboardState.addAlarm(newAlarm);
                    } else {
                      dashboardState.updateAlarm(newAlarm);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}