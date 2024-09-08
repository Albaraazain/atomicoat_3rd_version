import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class PressureControllerControls extends StatelessWidget {
  final ReactorState reactorState;

  PressureControllerControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Pressure Setpoint: ${reactorState.pressureSetpoint.toStringAsFixed(2)} mTorr'),
        Text('Actual Pressure: ${reactorState.actualPressure.toStringAsFixed(2)} mTorr'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showPressureDialog(context),
          child: Text('Set Pressure'),
        ),
      ],
    );
  }

  void _showPressureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newPressure = '';
        return AlertDialog(
          title: Text('Set Pressure Setpoint'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Pressure (mTorr)'),
            onChanged: (value) => newPressure = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newPressure.isNotEmpty) {
                  double pressure = double.parse(newPressure);
                  reactorState.setPressureSetpoint(pressure);
                }
                Navigator.pop(context);
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }
}