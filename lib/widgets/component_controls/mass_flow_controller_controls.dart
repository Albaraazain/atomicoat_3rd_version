import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class MassFlowControllerControls extends StatelessWidget {
  final ReactorState reactorState;

  MassFlowControllerControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Flow Rate: ${reactorState.mfcFlowRate.toStringAsFixed(2)} sccm'),
        Text('Pressure: ${reactorState.mfcPressure.toStringAsFixed(2)} mTorr'),
        Text('Correction: ${reactorState.mfcCorrection.toStringAsFixed(2)}%'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showFlowRateDialog(context),
          child: Text('Set Flow Rate'),
        ),
      ],
    );
  }

  void _showFlowRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newFlowRate = '';
        return AlertDialog(
          title: Text('Set Flow Rate'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Flow Rate (sccm)'),
            onChanged: (value) => newFlowRate = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newFlowRate.isNotEmpty) {
                  double flowRate = double.parse(newFlowRate);
                  reactorState.setMFCFlowRate(flowRate);
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