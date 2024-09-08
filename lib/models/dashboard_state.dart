// lib/models/dashboard_state.dart
import 'package:flutter/foundation.dart';
import '../services/mock_ald_service.dart';
import 'recipe.dart';

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

  late MockALDService _mockService;

  DashboardState() {
    _mockService = MockALDService(this);
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

  void updateParameters(double temp, double press, double flow) {
    _temperature = temp;
    _pressure = press;
    _gasFlow = flow;
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


  void _handleError(String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
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

