// lib/widgets/global_controls_bar.dart

import 'package:flutter/material.dart';
import '../models/reactor_state.dart';

class GlobalControlsBar extends StatelessWidget {
  final ReactorState reactorState;

  GlobalControlsBar({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: reactorState.isExecutingRecipe
                ? null
                : () => reactorState.startRecipeExecution(),
            child: Text('Start Recipe'),
          ),
          ElevatedButton(
            onPressed: reactorState.isExecutingRecipe
                ? () => reactorState.pauseRecipeExecution()
                : () => reactorState.resumeRecipeExecution(),
            child: Text(reactorState.isExecutingRecipe ? 'Pause' : 'Resume'),
          ),
          ElevatedButton(
            onPressed: () => reactorState.stopRecipeExecution(),
            child: Text('Stop'),
          ),
          ElevatedButton(
            onPressed: () => reactorState.emergencyShutdown(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Emergency Shutdown'),
          ),
        ],
      ),
    );
  }
}