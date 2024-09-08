// lib/services/ald_hardware_interface.dart

import 'dart:async';
import 'dart:math';

class ALDHardwareInterface {
  // Simulate hardware readings
  double _n2FlowRate = 20.0;
  List<double> _precursorTemperatures = [25.0, 32.0, 25.0];
  double _chamberTemperature = 25.0;
  double _chamberPressure = 1.0;
  double _mfcFlowRate = 0.0;
  double _mfcPressure = 0.0;
  double _mfcCorrection = 0.0;
  double _frontlineHeaterTemperature = 25.0;
  double _backlineHeaterTemperature = 25.0;
  double _pressureSetpoint = 1.0;

  // Simulate hardware control
  Timer? _updateTimer;

  void startUpdates(Function(Map<String, dynamic>) updateCallback) {
    _updateTimer = Timer.periodic(Duration(seconds: 1), (_) {
      updateCallback(_simulateReadings());
    });
  }

  void stopUpdates() {
    _updateTimer?.cancel();
  }

  Map<String, dynamic> _simulateReadings() {
    // Simulate some fluctuations
    _n2FlowRate += (Random().nextDouble() - 0.5) * 0.2;
    for (int i = 0; i < _precursorTemperatures.length; i++) {
      _precursorTemperatures[i] += (Random().nextDouble() - 0.5) * 0.1;
    }
    _chamberTemperature += (Random().nextDouble() - 0.5) * 0.1;
    _chamberPressure += (Random().nextDouble() - 0.5) * 0.01;
    _mfcFlowRate += (Random().nextDouble() - 0.5) * 0.1;
    _mfcPressure += (Random().nextDouble() - 0.5) * 0.01;
    _mfcCorrection += (Random().nextDouble() - 0.5) * 0.1;
    _frontlineHeaterTemperature += (Random().nextDouble() - 0.5) * 0.1;
    _backlineHeaterTemperature += (Random().nextDouble() - 0.5) * 0.1;

    return {
      'n2FlowRate': _n2FlowRate,
      'precursorTemperatures': _precursorTemperatures,
      'chamberTemperature': _chamberTemperature,
      'chamberPressure': _chamberPressure,
      'mfcFlowRate': _mfcFlowRate,
      'mfcPressure': _mfcPressure,
      'mfcCorrection': _mfcCorrection,
      'frontlineHeaterTemperature': _frontlineHeaterTemperature,
      'backlineHeaterTemperature': _backlineHeaterTemperature,
      'pressureSetpoint': _pressureSetpoint,
      'precursorContainers': [
        {'temperature': _precursorTemperatures[0], 'fillLevel': 80.0, 'status': 'Ready'},
        {'temperature': _precursorTemperatures[1], 'fillLevel': 75.0, 'status': 'Ready'},
        {'temperature': _precursorTemperatures[2], 'fillLevel': 90.0, 'status': 'Ready'},
      ],
    };
  }

  // Simulated control methods
  Future<void> setN2FlowRate(double rate) async {
    await Future.delayed(Duration(milliseconds: 500));
    _n2FlowRate = rate;
  }

  Future<void> setMFCFlowRate(double rate) async {
    await Future.delayed(Duration(milliseconds: 500));
    _mfcFlowRate = rate;
  }

  Future<void> setPrecursorTemperature(int index, double temperature) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (index >= 0 && index < _precursorTemperatures.length) {
      _precursorTemperatures[index] = temperature;
    } else {
      throw Exception('Invalid precursor index');
    }
  }

  Future<void> updatePrecursorFillLevel(int index, double fillLevel) async {
    await Future.delayed(Duration(milliseconds: 500));
    // In a real system, you would update the fill level of the precursor container
    print('Updated precursor $index fill level to $fillLevel%');
  }

  Future<void> setChamberTemperature(double temperature) async {
    await Future.delayed(Duration(milliseconds: 500));
    _chamberTemperature = temperature;
  }

  Future<void> setChamberPressure(double pressure) async {
    await Future.delayed(Duration(milliseconds: 500));
    _chamberPressure = pressure;
  }

  Future<void> setFrontlineHeaterTemperature(double temperature) async {
    await Future.delayed(Duration(milliseconds: 500));
    _frontlineHeaterTemperature = temperature;
  }

  Future<void> setBacklineHeaterTemperature(double temperature) async {
    await Future.delayed(Duration(milliseconds: 500));
    _backlineHeaterTemperature = temperature;
  }

  Future<void> setPressureSetpoint(double pressure) async {
    await Future.delayed(Duration(milliseconds: 500));
    _pressureSetpoint = pressure;
  }
}