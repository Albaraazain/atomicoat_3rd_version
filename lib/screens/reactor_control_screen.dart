import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reactor_state.dart';
import '../models/component_type.dart';
import '../widgets/interactive_system_diagram.dart';
import '../widgets/global_controls_bar.dart';
import '../widgets/alert_status_bar.dart';
import '../widgets/component_control_panel.dart';
import '../widgets/force_landscape.dart';

class ReactorControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ForceLandscape(
      child: Scaffold(
        body: Consumer<ReactorState>(
          builder: (context, reactorState, child) {
            return Stack(
              children: [
                InteractiveSystemDiagram(
                  reactorState: reactorState,
                  onTapComponent: (ComponentType type) {
                    _showComponentControlPanel(context, type, reactorState);
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GlobalControlsBar(reactorState: reactorState),
                      AlertStatusBar(reactorState: reactorState),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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