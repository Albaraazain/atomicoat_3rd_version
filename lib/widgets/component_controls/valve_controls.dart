import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class ValveControls extends StatelessWidget {
  final ReactorState reactorState;

  ValveControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < reactorState.valveStatuses.length; i++)
          Column(
            children: [
              Text('Valve ${i + 1} Status: ${reactorState.valveStatuses[i] ? 'Open' : 'Closed'}'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  reactorState.toggleValve(i);
                },
                child: Text(reactorState.valveStatuses[i] ? 'Close Valve ${i + 1}' : 'Open Valve ${i + 1}'),
              ),
              SizedBox(height: 16),
            ],
          ),
      ],
    );
  }
}