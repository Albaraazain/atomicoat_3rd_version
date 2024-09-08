import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class ChamberControls extends StatelessWidget {
  final ReactorState reactorState;

  ChamberControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Chamber Temperature: ${reactorState.chamberTemperature.toStringAsFixed(1)}°C'),
        SizedBox(height: 8),
        Text('Chamber Pressure: ${reactorState.chamberPressure.toStringAsFixed(2)} mTorr'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showTemperatureDialog(context),
          child: Text('Adjust Temperature'),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showPressureDialog(context),
          child: Text('Adjust Pressure'),
        ),
      ],
    );
  }

  void _showTemperatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newTemperature = '';
        return AlertDialog(
          title: Text('Set Chamber Temperature'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Temperature (°C)'),
            onChanged: (value) => newTemperature = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newTemperature.isNotEmpty) {
                  double temperature = double.parse(newTemperature);
                  reactorState.setChamberTemperature(temperature);
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

  void _showPressureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newPressure = '';
        return AlertDialog(
          title: Text('Set Chamber Pressure'),
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
                  reactorState.setChamberPressure(pressure);
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