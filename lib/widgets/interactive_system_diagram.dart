// lib/widgets/interactive_system_diagram.dart

import 'package:flutter/material.dart';
import '../models/reactor_state.dart';
import '../models/component_type.dart';

class InteractiveSystemDiagram extends StatelessWidget {
  final ReactorState reactorState;
  final Function(ComponentType) onComponentTap;

  InteractiveSystemDiagram({
    required this.reactorState,
    required this.onComponentTap,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4,
      child: Stack(
        children: [
          Image.asset('assets/ald_system_diagram.png'),
          _buildTappableAreas(),
        ],
      ),
    );
  }

  Widget _buildTappableAreas() {
    return Stack(
      children: [
        _buildTappableComponent(ComponentType.n2Generator, Rect.fromLTWH(50, 100, 50, 50)),
        _buildTappableComponent(ComponentType.massFlowController, Rect.fromLTWH(150, 100, 50, 50)),
        _buildTappableComponent(ComponentType.valve, Rect.fromLTWH(235, 35, 30, 30)),
        _buildTappableComponent(ComponentType.valve, Rect.fromLTWH(235, 85, 30, 30)),
        _buildTappableComponent(ComponentType.valve, Rect.fromLTWH(235, 135, 30, 30)),
        _buildTappableComponent(ComponentType.precursorContainer, Rect.fromLTWH(200, 25, 30, 50)),
        _buildTappableComponent(ComponentType.precursorContainer, Rect.fromLTWH(200, 75, 30, 50)),
        _buildTappableComponent(ComponentType.precursorContainer, Rect.fromLTWH(200, 125, 30, 50)),
        _buildTappableComponent(ComponentType.chamber, Rect.fromLTWH(310, 60, 80, 80)),
        _buildTappableComponent(ComponentType.heater, Rect.fromLTWH(300, 150, 40, 20)),
        _buildTappableComponent(ComponentType.pressureController, Rect.fromLTWH(450, 75, 50, 50)),
        _buildTappableComponent(ComponentType.pump, Rect.fromLTWH(550, 75, 50, 50)),
      ],
    );
  }

  Widget _buildTappableComponent(ComponentType type, Rect bounds) {
    return Positioned.fromRect(
      rect: bounds,
      child: GestureDetector(
        onTap: () => onComponentTap(type),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}