// lib/screens/reactor_control_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reactor_state.dart';
import '../models/component_type.dart';
import '../widgets/interactive_system_diagram.dart';
import '../widgets/global_controls_bar.dart';
import '../widgets/alert_status_bar.dart';
import '../widgets/component_control_panel.dart';

class ReactorControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reactor Control')),
      body: Consumer<ReactorState>(
        builder: (context, reactorState, child) {
          return Column(
            children: [
              Expanded(
                child: InteractiveSystemDiagram(
                  reactorState: reactorState,
                  onComponentTap: (ComponentType type) {
                    _showComponentControlPanel(context, type, reactorState);
                  },
                ),
              ),
              GlobalControlsBar(reactorState: reactorState),
              AlertStatusBar(reactorState: reactorState),
            ],
          );
        },
      ),
    );
  }

  void _showComponentControlPanel(BuildContext context, ComponentType type, ReactorState reactorState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ComponentControlPanel(type: type, reactorState: reactorState);
      },
    );
  }
}