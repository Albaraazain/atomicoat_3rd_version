// lib/widgets/component_control_panel.dart

import 'package:flutter/material.dart';
import '../models/reactor_state.dart';
import '../models/component_type.dart';
import 'component_controls/n2_generator_controls.dart';
import 'component_controls/mass_flow_controller_controls.dart';
import 'component_controls/valve_controls.dart';
import 'component_controls/precursor_container_controls.dart';
import 'component_controls/chamber_controls.dart';
import 'component_controls/heater_controls.dart';
import 'component_controls/pressure_controller_controls.dart';
import 'component_controls/pump_controls.dart';

class ComponentControlPanel extends StatelessWidget {
  final ComponentType type;
  final ReactorState reactorState;

  ComponentControlPanel({required this.type, required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Control Panel: ${type.toString().split('.').last}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildControlsForType(type),
        ],
      ),
    );
  }

  Widget _buildControlsForType(ComponentType type) {
    switch (type) {
      case ComponentType.n2Generator:
        return N2GeneratorControls(reactorState: reactorState);
      case ComponentType.massFlowController:
        return MassFlowControllerControls(reactorState: reactorState);
      case ComponentType.valve:
        return ValveControls(reactorState: reactorState);
      case ComponentType.precursorContainer:
        return PrecursorContainerControls(reactorState: reactorState);
      case ComponentType.chamber:
        return ChamberControls(reactorState: reactorState);
      case ComponentType.heater:
        return HeaterControls(reactorState: reactorState);
      case ComponentType.pressureController:
        return PressureControllerControls(reactorState: reactorState);
      case ComponentType.pump:
        return PumpControls(reactorState: reactorState);
      default:
        return Text('No controls available for this component');
    }
  }
}