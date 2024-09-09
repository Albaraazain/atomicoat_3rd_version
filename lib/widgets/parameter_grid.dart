import 'package:flutter/material.dart';
import '../styles/theme.dart';

class ParameterGrid extends StatelessWidget {
  final double temperature;
  final double pressure;
  final double gasFlow;
  final String temperatureTrend;
  final String pressureTrend;
  final String gasFlowTrend;

  const ParameterGrid({
    Key? key,
    required this.temperature,
    required this.pressure,
    required this.gasFlow,
    required this.temperatureTrend,
    required this.pressureTrend,
    required this.gasFlowTrend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key Parameters', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildParameterTile('Temperature', temperature, '°C', temperatureTrend)),
                Expanded(child: _buildParameterTile('Pressure', pressure, 'mTorr', pressureTrend)),
                Expanded(child: _buildParameterTile('Gas Flow', gasFlow, 'sccm', gasFlowTrend)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterTile(String label, double value, String unit, String trend) {
    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case 'up':
        trendIcon = Icons.arrow_upward;
        trendColor = Colors.red;
        break;
      case 'down':
        trendIcon = Icons.arrow_downward;
        trendColor = Colors.green;
        break;
      default:
        trendIcon = Icons.remove;
        trendColor = Colors.grey;
    }

    return Column(
      children: [
        Text(label, style: TextStyle(color: ALDColors.textLight)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ALDColors.text),
            ),
            SizedBox(width: 4),
            Icon(trendIcon, size: 16, color: trendColor),
          ],
        ),
      ],
    );
  }
}