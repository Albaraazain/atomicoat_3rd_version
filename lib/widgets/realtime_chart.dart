import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../styles/theme.dart';
import 'dart:math';

class RealtimeChart extends StatelessWidget {
  final List<double> temperatureData;
  final List<double> pressureData;
  final List<double> gasFlowData;
  final int maxDataPoints;

  const RealtimeChart({
    Key? key,
    required this.temperatureData,
    required this.pressureData,
    required this.gasFlowData,
    this.maxDataPoints = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.70,
          child: LineChart(mainData()),
        ),
        SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 25,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: ALDColors.divider,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: ALDColors.divider,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: rightTitleWidgets,
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 25,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: ALDColors.divider, width: 1)),
      minX: 0,
      maxX: maxDataPoints.toDouble() - 1,
      minY: 0,
      maxY: 3,
      lineBarsData: [
        _buildLineChartBarData(temperatureData, Colors.red, 0),
        _buildLineChartBarData(pressureData, Colors.blue, 1),
        _buildLineChartBarData(gasFlowData, Colors.green, 2),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(y: 1, color: Colors.red.withOpacity(0.3)),
          HorizontalLine(y: 2, color: Colors.blue.withOpacity(0.3)),
          HorizontalLine(y: 3, color: Colors.green.withOpacity(0.3)),
        ],
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(List<double> data, Color color, int index) {
    double maxValue = data.isNotEmpty ? data.reduce(max) : 1;
    return LineChartBarData(
      spots: data.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), (entry.value / maxValue) + index);
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ALDColors.textLight,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('0s', style: style);
        break;
      case 25:
        text = const Text('25s', style: style);
        break;
      case 50:
        text = const Text('50s', style: style);
        break;
      case 75:
        text = const Text('75s', style: style);
        break;
      case 99:
        text = const Text('Now', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ALDColors.textLight,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    if (value == 0 || value == 1 || value == 2 || value == 3) {
      return Text('', style: style);
    }
    double tempValue = value * (temperatureData.reduce(max) / 3);
    return Text('${tempValue.toStringAsFixed(0)}°C', style: style.copyWith(color: Colors.red));
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ALDColors.textLight,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    if (value == 1) {
      double pressureValue = pressureData.reduce(max);
      return Text('${pressureValue.toStringAsFixed(1)} mTorr', style: style.copyWith(color: Colors.blue));
    } else if (value == 3) {
      double gasFlowValue = gasFlowData.reduce(max);
      return Text('${gasFlowValue.toStringAsFixed(1)} sccm', style: style.copyWith(color: Colors.green));
    }
    return Text('', style: style);
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Temperature', Colors.red),
        SizedBox(width: 16),
        _buildLegendItem('Pressure', Colors.blue),
        SizedBox(width: 16),
        _buildLegendItem('Gas Flow', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(color: ALDColors.text)),
      ],
    );
  }
}