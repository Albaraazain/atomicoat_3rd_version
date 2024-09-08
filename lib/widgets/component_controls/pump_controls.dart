import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class PumpControls extends StatelessWidget {
  final ReactorState reactorState;

  PumpControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Pump Status: ${reactorState.pumpStatus ? 'On' : 'Off'}'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            reactorState.togglePump();
          },
          child: Text(reactorState.pumpStatus ? 'Turn Off Pump' : 'Turn On Pump'),
        ),
      ],
    );
  }
}