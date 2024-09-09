import 'package:flutter/material.dart';
import '../styles/theme.dart';

class SystemHealthIndicator extends StatelessWidget {
  final double overallHealth;
  final Map<String, double> components;
  final Function(String) onComponentTap;

  const SystemHealthIndicator({
    Key? key,
    required this.overallHealth,
    required this.components,
    required this.onComponentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Health', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            _buildOverallHealth(context),
            SizedBox(height: 16),
            Text('Component Health', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            ...components.entries.map((entry) => _buildComponentHealth(context, entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallHealth(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overall Health:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(_getHealthStatus(overallHealth), style: TextStyle(color: _getHealthColor(overallHealth))),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: overallHealth,
                backgroundColor: ALDColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(overallHealth)),
                strokeWidth: 10,
              ),
              Text(
                '${(overallHealth * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComponentHealth(BuildContext context, String component, double health) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onComponentTap(component),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(component),
            ),
            Expanded(
              flex: 2,
              child: LinearProgressIndicator(
                value: health,
                backgroundColor: ALDColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(health)),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${(health * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: _getHealthColor(health)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(double health) {
    if (health > 0.7) return Colors.green;
    if (health > 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getHealthStatus(double health) {
    if (health > 0.7) return 'Good';
    if (health > 0.4) return 'Needs Attention';
    return 'Critical';
  }
}