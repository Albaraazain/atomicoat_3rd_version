// lib/models/alarm.dart
import 'package:uuid/uuid.dart';

enum AlarmType {
  temperature,
  pressure,
  gasFlow,
}

enum AlarmCondition {
  lessThan,
  greaterThan,
}

class Alarm {
  final String id;
  final String name;
  final AlarmType type;
  final AlarmCondition condition;
  final double threshold;
  bool isActive;

  Alarm({
    String? id,
    required this.name,
    required this.type,
    required this.condition,
    required this.threshold,
    this.isActive = true,
  }) : id = id ?? Uuid().v4();

  bool checkCondition(double value) {
    switch (condition) {
      case AlarmCondition.lessThan:
        return value < threshold;
      case AlarmCondition.greaterThan:
        return value > threshold;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'condition': condition.toString(),
      'threshold': threshold,
      'isActive': isActive,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      name: json['name'],
      type: AlarmType.values.firstWhere((e) => e.toString() == json['type']),
      condition: AlarmCondition.values.firstWhere((e) => e.toString() == json['condition']),
      threshold: json['threshold'],
      isActive: json['isActive'],
    );
  }
}