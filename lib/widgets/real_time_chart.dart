import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/reactor_state.dart';

class RealTimeChart extends StatelessWidget {
  final ReactorState reactorState;

  RealTimeChart({required this.reactorState});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 60, // Show last 60 seconds
          minY: 0,
          maxY: 100, // Adjust based on your data range
          lineBarsData: [
            LineChartBarData(
              spots: _generateChartData(reactorState),
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData(ReactorState state) {
    // This is a placeholder. In a real app, you'd use actual historical data.
    List<FlSpot> spots = [];
    for (int i = 0; i < 60; i++) {
      spots.add(FlSpot(i.toDouble(), state.chamberTemperature));
    }
    return spots;
  }
}