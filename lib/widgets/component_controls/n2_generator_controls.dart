import 'package:flutter/material.dart';
import '../../models/reactor_state.dart';

class N2GeneratorControls extends StatelessWidget {
  final ReactorState reactorState;

  N2GeneratorControls({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Gas Purity: ${reactorState.n2Purity.toStringAsFixed(1)}%'),
        SizedBox(height: 8),
        Text('Flow Rate: ${reactorState.n2FlowRate.toStringAsFixed(1)} sccm'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showFlowRateDialog(context),
          child: Text('Adjust Flow Rate'),
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
          title: Text('Set N2 Flow Rate'),
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
                  reactorState.setN2FlowRate(flowRate);
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