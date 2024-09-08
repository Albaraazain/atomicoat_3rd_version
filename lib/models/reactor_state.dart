// lib/models/reactor_state.dart

import 'package:flutter/foundation.dart';
import '../services/ald_hardware_interface.dart';
import 'recipe.dart';
import '../services/logger.dart';
import 'alarm.dart';
import 'maintenance_task.dart';

class PrecursorContainer {
  double temperature;
  double fillLevel;
  String status;

  PrecursorContainer({
    this.temperature = 25.0,
    this.fillLevel = 100.0,
    this.status = 'Ready',
  });
}

class ReactorState extends ChangeNotifier {
  final ALDHardwareInterface _hardwareInterface = ALDHardwareInterface();

  // N2 Generator
  double _n2Purity = 99.9;
  double _n2FlowRate = 20.0;

  // Mass Flow Controller
  double _mfcFlowRate = 0.0;
  double _mfcPressure = 0.0;
  double _mfcCorrection = 0.0;

  // Valves
  List<bool> _valveStatuses = [false, false, false];

  // Precursor Containers
  List<PrecursorContainer> _precursorContainers = [
    PrecursorContainer(),
    PrecursorContainer(),
    PrecursorContainer(),
  ];

  // Chamber
  double _chamberTemperature = 25.0;
  double _chamberPressure = 1.0;

  // Heaters
  double _frontlineHeaterTemperature = 25.0;
  double _backlineHeaterTemperature = 25.0;

  // Pressure Controller
  double _pressureSetpoint = 1.0;
  double _actualPressure = 1.0;

  // Pump
  bool _pumpStatus = false;

  // System Status
  String _systemStatus = 'Normal';

  // Recipe Execution
  Recipe? _currentRecipe;
  int _currentStepIndex = 0;
  bool _isExecutingRecipe = false;

  // Alarms
  List<Alarm> _alarms = [];
  List<String> _activeAlarms = [];

  // Maintenance Tasks
  List<MaintenanceTask> _maintenanceTasks = [];

  // Logs
  List<LogEntry> _logEntries = [];

  // Getters
  double get n2Purity => _n2Purity;
  double get n2FlowRate => _n2FlowRate;
  double get mfcFlowRate => _mfcFlowRate;
  double get mfcPressure => _mfcPressure;
  double get mfcCorrection => _mfcCorrection;
  List<bool> get valveStatuses => _valveStatuses;
  List<PrecursorContainer> get precursorContainers => _precursorContainers;
  double get chamberTemperature => _chamberTemperature;
  double get chamberPressure => _chamberPressure;
  double get frontlineHeaterTemperature => _frontlineHeaterTemperature;
  double get backlineHeaterTemperature => _backlineHeaterTemperature;
  double get pressureSetpoint => _pressureSetpoint;
  double get actualPressure => _actualPressure;
  bool get pumpStatus => _pumpStatus;
  String get systemStatus => _systemStatus;
  Recipe? get currentRecipe => _currentRecipe;
  bool get isExecutingRecipe => _isExecutingRecipe;
  List<Alarm> get alarms => _alarms;
  List<String> get activeAlarms => _activeAlarms;
  List<MaintenanceTask> get maintenanceTasks => _maintenanceTasks;
  List<LogEntry> get logEntries => _logEntries;

  ReactorState() {
    _hardwareInterface.startUpdates(_updateReadings);
  }

  // N2 Generator methods
  Future<void> setN2FlowRate(double rate) async {
    try {
      await _hardwareInterface.setN2FlowRate(rate);
      _n2FlowRate = rate;
      Logger.log('N2 flow rate set to $rate sccm');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set N2 flow rate: $e');
      throw Exception('Failed to set N2 flow rate: $e');
    }
  }

  // Mass Flow Controller methods
  Future<void> setMFCFlowRate(double rate) async {
    try {
      await _hardwareInterface.setMFCFlowRate(rate);
      _mfcFlowRate = rate;
      Logger.log('MFC flow rate set to $rate sccm');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set MFC flow rate: $e');
      throw Exception('Failed to set MFC flow rate: $e');
    }
  }

  // Valve methods
  void toggleValve(int index) {
    if (index >= 0 && index < _valveStatuses.length) {
      _valveStatuses[index] = !_valveStatuses[index];
      Logger.log('Valve $index ${_valveStatuses[index] ? 'opened' : 'closed'}');
      notifyListeners();
    } else {
      _updateSystemStatus('Error');
      Logger.log('Invalid valve index: $index');
      throw ArgumentError('Invalid valve index');
    }
  }

  // Precursor Container methods
  Future<void> setPrecursorTemperature(int index, double temperature) async {
    try {
      await _hardwareInterface.setPrecursorTemperature(index, temperature);
      _precursorContainers[index].temperature = temperature;
      Logger.log('Precursor $index temperature set to $temperature°C');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set precursor temperature: $e');
      throw Exception('Failed to set precursor temperature: $e');
    }
  }

  Future<void> updatePrecursorFillLevel(int index, double fillLevel) async {
    try {
      await _hardwareInterface.updatePrecursorFillLevel(index, fillLevel);
      _precursorContainers[index].fillLevel = fillLevel;
      Logger.log('Precursor $index fill level updated to $fillLevel%');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to update precursor fill level: $e');
      throw Exception('Failed to update precursor fill level: $e');
    }
  }

  // Chamber methods
  Future<void> setChamberTemperature(double temperature) async {
    try {
      await _hardwareInterface.setChamberTemperature(temperature);
      _chamberTemperature = temperature;
      Logger.log('Chamber temperature set to $temperature°C');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set chamber temperature: $e');
      throw Exception('Failed to set chamber temperature: $e');
    }
  }

  Future<void> setChamberPressure(double pressure) async {
    try {
      await _hardwareInterface.setChamberPressure(pressure);
      _chamberPressure = pressure;
      Logger.log('Chamber pressure set to $pressure mTorr');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set chamber pressure: $e');
      throw Exception('Failed to set chamber pressure: $e');
    }
  }

  // Heater methods
  Future<void> setFrontlineHeaterTemperature(double temperature) async {
    try {
      await _hardwareInterface.setFrontlineHeaterTemperature(temperature);
      _frontlineHeaterTemperature = temperature;
      Logger.log('Frontline heater temperature set to $temperature°C');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set frontline heater temperature: $e');
      throw Exception('Failed to set frontline heater temperature: $e');
    }
  }

  Future<void> setBacklineHeaterTemperature(double temperature) async {
    try {
      await _hardwareInterface.setBacklineHeaterTemperature(temperature);
      _backlineHeaterTemperature = temperature;
      Logger.log('Backline heater temperature set to $temperature°C');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set backline heater temperature: $e');
      throw Exception('Failed to set backline heater temperature: $e');
    }
  }

  // Pressure Controller methods
  Future<void> setPressureSetpoint(double pressure) async {
    try {
      await _hardwareInterface.setPressureSetpoint(pressure);
      _pressureSetpoint = pressure;
      Logger.log('Pressure setpoint set to $pressure mTorr');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to set pressure setpoint: $e');
      throw Exception('Failed to set pressure setpoint: $e');
    }
  }

  // Pump methods
  void togglePump() {
    _pumpStatus = !_pumpStatus;
    Logger.log('Pump ${_pumpStatus ? 'started' : 'stopped'}');
    notifyListeners();
  }

  // Recipe methods
  Future<void> loadRecipe(Recipe recipe) async {
    _currentRecipe = recipe;
    _currentStepIndex = 0;
    Logger.log('Recipe loaded: ${recipe.name}');
    notifyListeners();
  }

  Future<void> startRecipeExecution() async {
    if (_currentRecipe == null) {
      Logger.log('No recipe loaded');
      throw Exception('No recipe loaded');
    }
    _isExecutingRecipe = true;
    Logger.log('Starting recipe execution: ${_currentRecipe!.name}');
    notifyListeners();
    await _executeRecipe();
  }

  Future<void> _executeRecipe() async {
    while (_currentStepIndex < _currentRecipe!.steps.length && _isExecutingRecipe) {
      await _executeStep(_currentRecipe!.steps[_currentStepIndex]);
      _currentStepIndex++;
      notifyListeners();
    }
    _isExecutingRecipe = false;
    Logger.log('Recipe execution completed: ${_currentRecipe!.name}');
    notifyListeners();
  }

  Future<void> _executeStep(RecipeStep step) async {
    Logger.log('Executing step: ${step.type}');
    switch (step.type) {
      case StepType.valve:
        await _executeValveStep(step);
        break;
      case StepType.purge:
        await _executePurgeStep(step);
        break;
      case StepType.loop:
        await _executeLoopStep(step);
        break;
    }
  }

  Future<void> _executeValveStep(RecipeStep step) async {
    ValveType valveType = step.parameters['valveType'];
    int duration = step.parameters['duration'];
    int valveIndex = valveType == ValveType.valveA ? 0 : 1;
    toggleValve(valveIndex);
    Logger.log('Valve ${valveType.toString().split('.').last} opened for $duration seconds');
    await Future.delayed(Duration(seconds: duration));
    toggleValve(valveIndex);
  }

  Future<void> _executePurgeStep(RecipeStep step) async {
    int duration = step.parameters['duration'];
    // Implement purge logic here
    Logger.log('Purging for $duration seconds');
    await Future.delayed(Duration(seconds: duration));
  }

  Future<void> _executeLoopStep(RecipeStep step) async {
    int iterations = step.parameters['iterations'];
    List<RecipeStep>? subSteps = step.subSteps;
    if (subSteps != null) {
      for (int i = 0; i < iterations; i++) {
        Logger.log('Executing loop iteration ${i + 1} of $iterations');
        for (RecipeStep subStep in subSteps) {
          await _executeStep(subStep);
        }
      }
    }
  }

  void pauseRecipeExecution() {
    _isExecutingRecipe = false;
    Logger.log('Recipe execution paused');
    notifyListeners();
  }

  void resumeRecipeExecution() {
    _isExecutingRecipe = true;
    Logger.log('Recipe execution resumed');
    notifyListeners();
    _executeRecipe();
  }

  void stopRecipeExecution() {
    _isExecutingRecipe = false;
    _currentStepIndex = 0;
    Logger.log('Recipe execution stopped');
    notifyListeners();
  }

  // Alarm methods
  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    Logger.log('Alarm added: ${alarm.name}');
    notifyListeners();
  }

  void removeAlarm(String id) {
    _alarms.removeWhere((alarm) => alarm.id == id);
    Logger.log('Alarm removed: $id');
    notifyListeners();
  }

  void updateAlarm(Alarm updatedAlarm) {
    int index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      Logger.log('Alarm updated: ${updatedAlarm.name}');
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
            isTriggered = alarm.checkCondition(_chamberTemperature);
            break;
          case AlarmType.pressure:
            isTriggered = alarm.checkCondition(_chamberPressure);
            break;
          case AlarmType.gasFlow:
            isTriggered = alarm.checkCondition(_n2FlowRate);
            break;
        }
        if (isTriggered) {
          _activeAlarms.add(alarm.name);
          Logger.log('Alarm triggered: ${alarm.name}');
        }
      }
    }
    if (_activeAlarms.isNotEmpty) {
      notifyListeners();
    }
  }

  // Maintenance task methods
  void addMaintenanceTask(MaintenanceTask task) {
    _maintenanceTasks.add(task);
    Logger.log('Maintenance task added: ${task.name}');
    notifyListeners();
  }

  void updateMaintenanceTask(MaintenanceTask updatedTask) {
    int index = _maintenanceTasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _maintenanceTasks[index] = updatedTask;
      Logger.log('Maintenance task updated: ${updatedTask.name}');
      notifyListeners();
    }
  }

  void removeMaintenanceTask(String id) {
    _maintenanceTasks.removeWhere((task) => task.id == id);
    Logger.log('Maintenance task removed: $id');
    notifyListeners();
  }

  void completeMaintenanceTask(String id) {
    int index = _maintenanceTasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _maintenanceTasks[index].markAsCompleted();
      Logger.log('Maintenance task completed: ${_maintenanceTasks[index].name}');
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
      Logger.log('Maintenance task due: ${task.name}');
    }
  }

  // Logging methods
  void addLogEntry(String description, DateTime timestamp) {
    _logEntries.add(LogEntry(description, timestamp));
    Logger.log('Log entry added: $description');
    notifyListeners();
  }

  void clearLog() {
    _logEntries.clear();
    Logger.log('Log cleared');
    notifyListeners();
  }

  // Update methods
  void _updateReadings(Map<String, dynamic> readings) {
    _n2FlowRate = readings['n2FlowRate'];
    _mfcFlowRate = readings['mfcFlowRate'];
    _mfcPressure = readings['mfcPressure'];
    _mfcCorrection = readings['mfcCorrection'];
    _chamberTemperature = readings['chamberTemperature'];
    _chamberPressure = readings['chamberPressure'];
    _actualPressure = readings['actualPressure'];

    List<Map<String, dynamic>> precursorData = readings['precursorContainers'];
    for (int i = 0; i < precursorData.length; i++) {
      _precursorContainers[i].temperature = precursorData[i]['temperature'];
      _precursorContainers[i].fillLevel = precursorData[i]['fillLevel'];
      _precursorContainers[i].status = precursorData[i]['status'];
    }

    checkAlarms();
    checkMaintenanceTasks();
    notifyListeners();
  }

  void _updateSystemStatus(String status) {
    _systemStatus = status;
    Logger.log('System status updated: $status');
    notifyListeners();
  }

  // Process control methods
  Future<void> startProcess() async {
    try {
      // Implement start process logic
      _updateSystemStatus('Running');
      Logger.log('Process started');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to start process: $e');
      throw Exception('Failed to start process: $e');
    }
  }

  Future<void> stopProcess() async {
    try {
      // Implement stop process logic
      _updateSystemStatus('Stopped');
      Logger.log('Process stopped');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to stop process: $e');
      throw Exception('Failed to stop process: $e');
    }
  }

  Future<void> emergencyShutdown() async {
    try {
      // Implement emergency shutdown logic
      _updateSystemStatus('Emergency Shutdown');
      Logger.log('Emergency shutdown initiated');
      notifyListeners();
    } catch (e) {
      _updateSystemStatus('Error');
      Logger.log('Failed to perform emergency shutdown: $e');
      throw Exception('Failed to perform emergency shutdown: $e');
    }
  }

  @override
  void dispose() {
    _hardwareInterface.stopUpdates();
    super.dispose();
  }
}

class LogEntry {
  final String description;
  final DateTime timestamp;

  LogEntry(this.description, this.timestamp);
}