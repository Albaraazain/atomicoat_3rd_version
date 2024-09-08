// lib/services/mock_ald_service.dart
import 'dart:async';
import 'dart:math';
import '../models/dashboard_state.dart';
import '../models/recipe.dart';

class MockALDService {
  final DashboardState dashboardState;
  Timer? _timer;
  final Random _random = Random();
  late Recipe _currentRecipe;
  int _totalSteps = 0;
  int _currentStepIndex = 0;
  int _currentStepProgress = 0;
  List<RecipeStep> _flattenedSteps = [];
  List<LoopInfo> _loopStack = [];

  MockALDService(this.dashboardState);

  void startSimulation(Recipe recipe) {
    _currentRecipe = recipe;
    _flattenedSteps = _flattenRecipe(recipe.steps);
    _totalSteps = _flattenedSteps.length;
    _currentStepIndex = 0;
    _currentStepProgress = 0;
    _loopStack = [];
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateState());
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }

  List<RecipeStep> _flattenRecipe(List<RecipeStep> steps, {int loopIterations = 1}) {
    List<RecipeStep> flattened = [];
    for (var step in steps) {
      if (step.type == StepType.loop) {
        int iterations = step.parameters['iterations'] as int;
        for (int i = 0; i < iterations * loopIterations; i++) {
          flattened.addAll(_flattenRecipe(step.subSteps ?? [], loopIterations: loopIterations));
        }
      } else {
        for (int i = 0; i < loopIterations; i++) {
          flattened.add(step);
        }
      }
    }
    return flattened;
  }

  int calculateTotalSteps(List<RecipeStep> steps) {
    return _flattenRecipe(steps).length;
  }

  void _updateState() {
    try {
      if (_currentStepIndex >= _totalSteps) {
        stopSimulation();
        dashboardState.stopProcess();
        return;
      }

      RecipeStep currentStep = _flattenedSteps[_currentStepIndex];
      String stepDescription = _getStepDescription(currentStep);
      int stepDuration = _getStepDuration(currentStep);

      _currentStepProgress++;

      // Update status
      String elapsedTime = _formatDuration(Duration(seconds: _currentStepIndex + _currentStepProgress));
      String estimatedCompletion = _formatDuration(Duration(seconds: _totalSteps - _currentStepIndex - _currentStepProgress));
      dashboardState.updateStatus(stepDescription, elapsedTime, estimatedCompletion, loopStack: _loopStack);

      // Add log entry only when starting a new step
      if (_currentStepProgress == 1) {
        dashboardState.addLogEntry(stepDescription, DateTime.now());
      }

      // Update parameters with some random fluctuations
      double temperature = 200 + _random.nextDouble() * 2 - 1;
      double pressure = 10 + _random.nextDouble() * 0.5 - 0.25;
      double gasFlow = 20 + _random.nextDouble() * 1 - 0.5;
      dashboardState.updateParameters(temperature, pressure, gasFlow);

      // Occasionally add an alert
      if (_random.nextInt(30) == 0) {
        dashboardState.addAlert('Parameter fluctuation detected');
      }

      // Move to next step if current step is completed
      if (_currentStepProgress >= stepDuration) {
        _currentStepIndex++;
        _currentStepProgress = 0;
      }

    } catch (e) {
      dashboardState.addAlert('Error in simulation: $e');
      dashboardState.addLogEntry('Error in simulation: $e', DateTime.now());
      stopSimulation();
    }
  }

  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        String valveType = step.parameters['valveType'] == ValveType.valveA ? 'A' : 'B';
        int duration = step.parameters['duration'] as int;
        return 'Valve $valveType open for $duration seconds';
      case StepType.purge:
        int duration = step.parameters['duration'] as int;
        return 'Purging for $duration seconds';
      default:
        return 'Unknown step type';
    }
  }

  int _getStepDuration(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
      case StepType.purge:
        return step.parameters['duration'] as int;
      default:
        return 1; // Default duration for unknown step types
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}