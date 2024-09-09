import 'package:flutter/material.dart';
import '../models/reactor_state.dart';
import '../models/component_type.dart';
import '../widgets/component_controls/chamber_controls.dart';
import '../widgets/component_controls/heater_controls.dart';
import '../widgets/component_controls/mass_flow_controller_controls.dart';
import '../widgets/component_controls/n2_generator_controls.dart';
import '../widgets/component_controls/precursor_container_controls.dart';
import '../widgets/component_controls/pressure_controller_controls.dart';
import '../widgets/component_controls/pump_controls.dart';
import '../widgets/component_controls/valve_controls.dart';

class InteractiveSystemDiagram extends StatefulWidget {
  final ReactorState reactorState;
  final Function(ComponentType) onTapComponent;

  InteractiveSystemDiagram({
    required this.reactorState,
    required this.onTapComponent,
  });

  @override
  _InteractiveSystemDiagramState createState() => _InteractiveSystemDiagramState();
}

class _InteractiveSystemDiagramState extends State<InteractiveSystemDiagram> {
  final double originalWidth = 5831.0;
  final double originalHeight = 2887.0;

  final TransformationController _transformationController = TransformationController();
  ComponentDot? selectedDot;

  List<ComponentDot> componentDots = [
    ComponentDot(ComponentType.n2Generator, Offset(981.13, 1264.55), 'N2'),
    ComponentDot(ComponentType.massFlowController, Offset(1314.0, 1275.01), 'MFC'),
    ComponentDot(ComponentType.valve, Offset(1595.7, 1624.0), 'V1'),
    ComponentDot(ComponentType.valve, Offset(1919.33, 1620.83), 'V2'),
    ComponentDot(ComponentType.precursorContainer, Offset(3657.23, 1936.75), 'P1'),
    ComponentDot(ComponentType.precursorContainer, Offset(4128.03, 1778.6), 'P2'),
    ComponentDot(ComponentType.chamber, Offset(2786.2, 1297.9), 'Ch'),
    ComponentDot(ComponentType.heater, Offset(1810.22, 1307.44), 'FH'),
    ComponentDot(ComponentType.heater, Offset(3492.95, 1299.57), 'BH'),
    ComponentDot(ComponentType.pressureController, Offset(4193.26, 960.82), 'PC'),
    ComponentDot(ComponentType.pump, Offset(4812.59, 1223.85), 'Pu'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double scaleX = constraints.maxWidth / originalWidth;
        double scaleY = constraints.maxHeight / originalHeight;
        double scale = scaleX > scaleY ? scaleX : scaleY;

        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/ald_system_diagram.png',
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  ...componentDots.map((dot) => _buildComponentDot(dot, scale, constraints)),
                ],
              ),
            ),
            if (selectedDot != null)
              _buildComponentControlPanel(selectedDot!, constraints),
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                child: Icon(Icons.zoom_out_map),
                onPressed: _resetZoom,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildComponentDot(ComponentDot dot, double scale, BoxConstraints constraints) {
    double dotX = (dot.position.dx * scale) - (originalWidth * scale - constraints.maxWidth) / 2;
    double dotY = (dot.position.dy * scale) - (originalHeight * scale - constraints.maxHeight) / 2;

    return Positioned(
      left: dotX - 7,
      top: dotY - 7,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDot = (selectedDot == dot) ? null : dot;
          });
          if (selectedDot != null) {
            widget.onTapComponent(selectedDot!.type);
          }
        },
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: _getStatusColor(dot.type),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ComponentType type) {
    switch (type) {
      case ComponentType.n2Generator:
        return widget.reactorState.n2FlowRate > 10 ? Colors.green : Colors.red;
      case ComponentType.massFlowController:
        return widget.reactorState.mfcFlowRate > 0 ? Colors.green : Colors.yellow;
      case ComponentType.valve:
        return widget.reactorState.valveStatuses[0] ? Colors.green : Colors.red;
      case ComponentType.precursorContainer:
        return widget.reactorState.precursorContainers[0].fillLevel > 20 ? Colors.green : Colors.red;
      case ComponentType.chamber:
        return widget.reactorState.chamberTemperature > 100 && widget.reactorState.chamberTemperature < 300 ? Colors.green : Colors.red;
      case ComponentType.heater:
        return widget.reactorState.frontlineHeaterTemperature > 50 ? Colors.orange : Colors.blue;
      case ComponentType.pressureController:
        return widget.reactorState.chamberPressure < 10 ? Colors.green : Colors.red;
      case ComponentType.pump:
        return widget.reactorState.pumpStatus ? Colors.green : Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildComponentControlPanel(ComponentDot dot, BoxConstraints constraints) {
    return Positioned(
      right: 10,
      top: 10,
      child: Container(
        width: constraints.maxWidth * 0.3,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: _getComponentControlWidget(dot.type),
      ),
    );
  }

  Widget _getComponentControlWidget(ComponentType type) {
    switch (type) {
      case ComponentType.n2Generator:
        return N2GeneratorControls(reactorState: widget.reactorState);
      case ComponentType.massFlowController:
        return MassFlowControllerControls(reactorState: widget.reactorState);
      case ComponentType.valve:
        return ValveControls(reactorState: widget.reactorState);
      case ComponentType.precursorContainer:
        return PrecursorContainerControls(reactorState: widget.reactorState);
      case ComponentType.chamber:
        return ChamberControls(reactorState: widget.reactorState);
      case ComponentType.heater:
        return HeaterControls(reactorState: widget.reactorState);
      case ComponentType.pressureController:
        return PressureControllerControls(reactorState: widget.reactorState);
      case ComponentType.pump:
        return PumpControls(reactorState: widget.reactorState);
      default:
        return Text('No controls available for this component');
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }
}

class ComponentDot {
  final ComponentType type;
  final Offset position;
  final String label;

  ComponentDot(this.type, this.position, this.label);
}