// lib/screens/maintenance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_state.dart';
import '../models/maintenance_task.dart';

class MaintenanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showMaintenanceTaskDialog(context),
          ),
        ],
      ),
      body: Consumer<DashboardState>(
        builder: (context, dashboardState, child) {
          return ListView.builder(
            itemCount: dashboardState.maintenanceTasks.length,
            itemBuilder: (context, index) {
              final task = dashboardState.maintenanceTasks[index];
              return ListTile(
                title: Text(task.name),
                subtitle: Text('Due: ${task.dueDate.toString().split(' ')[0]}'),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    if (value == true) {
                      dashboardState.completeMaintenanceTask(task.id);
                    } else {
                      dashboardState.updateMaintenanceTask(task.copyWith(isCompleted: false));
                    }
                  },
                ),
                onTap: () => _showMaintenanceTaskDialog(context, task: task),
              );
            },
          );
        },
      ),
    );
  }

  void _showMaintenanceTaskDialog(BuildContext context, {MaintenanceTask? task}) {
    final nameController = TextEditingController(text: task?.name ?? '');
    final descriptionController = TextEditingController(text: task?.description ?? '');
    DateTime selectedDate = task?.dueDate ?? DateTime.now();
    RecurrenceType selectedRecurrence = task?.recurrence ?? RecurrenceType.once;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(task == null ? 'Add Maintenance Task' : 'Edit Maintenance Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Task Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    ListTile(
                      title: Text("Due Date"),
                      subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate)
                          setState(() {
                            selectedDate = picked;
                          });
                      },
                    ),
                    DropdownButton<RecurrenceType>(
                      value: selectedRecurrence,
                      onChanged: (RecurrenceType? newValue) {
                        setState(() {
                          selectedRecurrence = newValue!;
                        });
                      },
                      items: RecurrenceType.values.map((RecurrenceType type) {
                        return DropdownMenuItem<RecurrenceType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
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
                  child: Text(task == null ? 'Add' : 'Update'),
                  onPressed: () {
                    final dashboardState = Provider.of<DashboardState>(context, listen: false);
                    final newTask = MaintenanceTask(
                      id: task?.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      dueDate: selectedDate,
                      recurrence: selectedRecurrence,
                      isCompleted: task?.isCompleted ?? false,
                    );
                    if (task == null) {
                      dashboardState.addMaintenanceTask(newTask);
                    } else {
                      dashboardState.updateMaintenanceTask(newTask);
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