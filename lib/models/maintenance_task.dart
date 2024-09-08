// lib/models/maintenance_task.dart
import 'package:uuid/uuid.dart';

enum RecurrenceType {
  once,
  daily,
  weekly,
  monthly,
  yearly,
}

class MaintenanceTask {
  final String id;
  String name;
  String description;
  DateTime dueDate;
  RecurrenceType recurrence;
  bool isCompleted;

  MaintenanceTask({
    String? id,
    required this.name,
    required this.description,
    required this.dueDate,
    this.recurrence = RecurrenceType.once,
    this.isCompleted = false,
  }) : id = id ?? Uuid().v4();

  MaintenanceTask copyWith({
    String? name,
    String? description,
    DateTime? dueDate,
    RecurrenceType? recurrence,
    bool? isCompleted,
  }) {
    return MaintenanceTask(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  void markAsCompleted() {
    isCompleted = true;
    updateDueDate();
  }

  void updateDueDate() {
    if (recurrence != RecurrenceType.once) {
      switch (recurrence) {
        case RecurrenceType.daily:
          dueDate = dueDate.add(Duration(days: 1));
          break;
        case RecurrenceType.weekly:
          dueDate = dueDate.add(Duration(days: 7));
          break;
        case RecurrenceType.monthly:
          dueDate = DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
          break;
        case RecurrenceType.yearly:
          dueDate = DateTime(dueDate.year + 1, dueDate.month, dueDate.day);
          break;
        default:
          break;
      }
      isCompleted = false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'recurrence': recurrence.toString(),
      'isCompleted': isCompleted,
    };
  }

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      recurrence: RecurrenceType.values.firstWhere((e) => e.toString() == json['recurrence']),
      isCompleted: json['isCompleted'],
    );
  }
}