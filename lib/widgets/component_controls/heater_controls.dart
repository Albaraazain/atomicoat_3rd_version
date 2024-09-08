import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class HeaterControls extends StatelessWidget {
  final ReactorState reactorState;

  HeaterControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Frontline Heater: ${reactorState.frontlineHeaterTemperature.toStringAsFixed(1)}°C'),
        Text('Backline Heater: ${reactorState.backlineHeaterTemperature.toStringAsFixed(1)}°C'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showHeaterDialog(context, true),
          child: Text('Set Frontline Temperature'),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showHeaterDialog(context, false),
          child: Text('Set Backline Temperature'),
        ),
      ],
    );
  }

  void _showHeaterDialog(BuildContext context, bool isFrontline) {
    showDialog(
      context: context,
      builder: (context) {
        String newTemperature = '';
        return AlertDialog(
          title: Text('Set ${isFrontline ? 'Frontline' : 'Backline'} Heater Temperature'),
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
                  if (isFrontline) {
                    reactorState.setFrontlineHeaterTemperature(temperature);
                  } else {
                    reactorState.setBacklineHeaterTemperature(temperature);
                  }
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