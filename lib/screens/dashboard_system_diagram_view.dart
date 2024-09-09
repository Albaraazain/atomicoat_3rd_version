import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/force_landscape.dart';
import '../widgets/interactive_system_diagram.dart';
import '../models/reactor_state.dart';
import '../models/component_type.dart';
import '../widgets/component_control_panel.dart';

class DashboardSystemDiagramView extends StatelessWidget {
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
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
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
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: ComponentControlPanel(type: type, reactorState: reactorState),
          ),
        );
      },
    );
  }
}