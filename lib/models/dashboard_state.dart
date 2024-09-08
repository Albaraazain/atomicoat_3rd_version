// lib/models/dashboard_state.dart
import 'package:flutter/foundation.dart';
import '../services/mock_ald_service.dart';
import '../services/notification_service.dart';
import 'alarm.dart';
import 'recipe.dart';
import 'maintenance_task.dart';


class DashboardState extends ChangeNotifier {
  String _currentStep = 'Idle';
  String _elapsedTime = '00:00:00';
  String _estimatedCompletion = '00:00:00';
  double _temperature = 0.0;
  double _pressure = 0.0;
  double _gasFlow = 0.0;
  List<Map<String, String>> _recentAlerts = [];
  String? _errorMessage;
  Recipe? _currentRecipe;
  List<LoopInfo> _currentLoopStack = [];
  int _currentStepIndex = 0;
  int _totalSteps = 0;
  List<LogEntry> _logEntries = [];
  List<Alarm> _alarms = [];
  List<String> _activeAlarms = [];
  List<MaintenanceTask> _maintenanceTasks = [];



  late MockALDService _mockService;
  late NotificationService _notificationService;

  DashboardState() {
    _mockService = MockALDService(this);
    _notificationService = NotificationService();
  }
  
  String get currentStep => _currentStep;
  String get elapsedTime => _elapsedTime;
  String get estimatedCompletion => _estimatedCompletion;
  double get temperature => _temperature;
  double get pressure => _pressure;
  double get gasFlow => _gasFlow;
  List<Map<String, String>> get recentAlerts => _recentAlerts;
  String? get errorMessage => _errorMessage;
  Recipe? get currentRecipe => _currentRecipe;
  List<LoopInfo> get currentLoopStack => _currentLoopStack;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _totalSteps;

  List<LogEntry> get logEntries => _logEntries;

  List<Alarm> get alarms => _alarms;
  List<String> get activeAlarms => _activeAlarms;

  List<MaintenanceTask> get maintenanceTasks => _maintenanceTasks;


  void addMaintenanceTask(MaintenanceTask task) {
    _maintenanceTasks.add(task);
    _notificationService.scheduleNotification(task);
    notifyListeners();
  }

  void updateMaintenanceTask(MaintenanceTask updatedTask) {
    int index = _maintenanceTasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _maintenanceTasks[index] = updatedTask;
      _notificationService.cancelNotification(updatedTask);
      _notificationService.scheduleNotification(updatedTask);
      notifyListeners();
    }
  }

  void removeMaintenanceTask(String id) {
    final task = _maintenanceTasks.firstWhere((task) => task.id == id);
    _maintenanceTasks.remove(task);
    _notificationService.cancelNotification(task);
    notifyListeners();
  }

  void completeMaintenanceTask(String id) {
    int index = _maintenanceTasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _maintenanceTasks[index].markAsCompleted();
      _notificationService.cancelNotification(_maintenanceTasks[index]);
      if (_maintenanceTasks[index].recurrence != RecurrenceType.once) {
        _notificationService.scheduleNotification(_maintenanceTasks[index]);
      }
      notifyListeners();
    }
  }


  List<MaintenanceTask> getDueMaintenanceTasks() {
    final now = DateTime.now();
    return _maintenanceTasks.where((task) => !task.isCompleted && task.dueDate.isBefore(now)).toList();
  }

  void checkMaintenanceTasks() {
    final dueTasks = getDueMaintenanceTasks();
    for (var task in dueTasks) {
      addAlert('Maintenance task due: ${task.name}');
    }
  }


  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    notifyListeners();
  }

  void removeAlarm(String id) {
    _alarms.removeWhere((alarm) => alarm.id == id);
    notifyListeners();
  }

  void updateAlarm(Alarm updatedAlarm) {
    int index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      notifyListeners();
    }
  }

  void checkAlarms() {
    _activeAlarms.clear();
    for (var alarm in _alarms) {
      if (alarm.isActive) {
        bool isTriggered = false;
        switch (alarm.type) {
          case AlarmType.temperature:
            isTriggered = alarm.checkCondition(_temperature);
            break;
          case AlarmType.pressure:
            isTriggered = alarm.checkCondition(_pressure);
            break;
          case AlarmType.gasFlow:
            isTriggered = alarm.checkCondition(_gasFlow);
            break;
        }
        if (isTriggered) {
          _activeAlarms.add(alarm.name);
          addAlert('Alarm triggered: ${alarm.name}');
        }
      }
    }
    if (_activeAlarms.isNotEmpty) {
      notifyListeners();
    }
  }

  void setCurrentRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    _totalSteps = _mockService.calculateTotalSteps(recipe.steps);
    notifyListeners();
  }

  void startProcess() {
    if (_currentRecipe == null) {
      _errorMessage = "No recipe selected. Please select a recipe before starting the process.";
      notifyListeners();
      return;
    }
    _currentStepIndex = 0;
    _totalSteps = _mockService.calculateTotalSteps(_currentRecipe!.steps);
    updateStatus('Starting process', '00:00:00', _calculateEstimatedCompletion());
    addAlert('Process started with recipe: ${_currentRecipe!.name}');
    addLogEntry('Process started with recipe: ${_currentRecipe!.name}', DateTime.now());
    _mockService.startSimulation(_currentRecipe!);
    _errorMessage = null;
    notifyListeners();
  }

  void updateStatus(String step, String elapsed, String estimated, {List<LoopInfo>? loopStack}) {
    _currentStep = step;
    _elapsedTime = elapsed;
    _estimatedCompletion = estimated;
    if (loopStack != null) {
      _currentLoopStack = loopStack;
    }
    notifyListeners();
  }

  @override
  void updateParameters(double temp, double press, double flow) {
    _temperature = temp;
    _pressure = press;
    _gasFlow = flow;
    checkAlarms();
    checkMaintenanceTasks();
    notifyListeners();
  }

  void addAlert(String message) {
    _recentAlerts.insert(0, {
      'message': message,
      'time': DateTime.now().toString(),
    });
    if (_recentAlerts.length > 5) {
      _recentAlerts.removeLast();
    }
    notifyListeners();
  }

  void addLogEntry(String description, DateTime timestamp) {
    _logEntries.add(LogEntry(description, timestamp));
    notifyListeners();
  }

  void clearLog() {
    _logEntries.clear();
    notifyListeners();
  }



  @override
  void stopProcess() {
    updateStatus('Stopped', _elapsedTime, '00:00:00');
    addAlert('Process stopped');
    addLogEntry('Process stopped', DateTime.now());
    _mockService.stopSimulation();
    _currentLoopStack.clear();
    _currentStepIndex = 0;
  }


  void pauseProcess() {
    updateStatus('Paused', _elapsedTime, _estimatedCompletion);
    addAlert('Process paused');
    _mockService.stopSimulation();
  }

  String _calculateEstimatedCompletion() {
    if (_currentRecipe == null) return '00:00:00';
    int totalSeconds = _totalSteps; // Now _totalSteps represents the total duration in seconds
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class LogEntry {
final String description;
final DateTime timestamp;

LogEntry(this.description, this.timestamp);
}

class LoopInfo {
  final int totalIterations;
  final int currentIteration;

  LoopInfo(this.totalIterations, this.currentIteration);
}

