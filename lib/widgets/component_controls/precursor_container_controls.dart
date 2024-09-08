// lib/widgets/component_controls/precursor_container_controls.dart

import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class PrecursorContainerControls extends StatelessWidget {
  final ReactorState reactorState;

  PrecursorContainerControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < reactorState.precursorContainers.length; i++)
          _buildPrecursorContainerControl(context, i),
      ],
    );
  }

  Widget _buildPrecursorContainerControl(BuildContext context, int index) {
    final container = reactorState.precursorContainers[index];
    return Column(
      children: [
        Text('Precursor ${index + 1}:'),
        Text('Temperature: ${container.temperature.toStringAsFixed(1)}°C'),
        Text('Fill Level: ${container.fillLevel.toStringAsFixed(1)}%'),
        Text('Status: ${container.status}'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showTemperatureDialog(context, index),
          child: Text('Set Temperature'),
        ),
        ElevatedButton(
          onPressed: () => _showFillLevelDialog(context, index),
          child: Text('Update Fill Level'),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _showTemperatureDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        String newTemperature = '';
        return AlertDialog(
          title: Text('Set Precursor ${index + 1} Temperature'),
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
                  reactorState.setPrecursorTemperature(index, temperature);
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

  void _showFillLevelDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        String newFillLevel = '';
        return AlertDialog(
          title: Text('Update Precursor ${index + 1} Fill Level'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Fill Level (%)'),
            onChanged: (value) => newFillLevel = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newFillLevel.isNotEmpty) {
                  double fillLevel = double.parse(newFillLevel);
                  reactorState.updatePrecursorFillLevel(index, fillLevel);
                }
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}