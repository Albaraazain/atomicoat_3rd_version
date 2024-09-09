import 'package:flutter/material.dart';
import '../styles/theme.dart';

class StatusOverview extends StatelessWidget {
  final String currentStep;
  final String elapsedTime;
  final String estimatedCompletion;
  final double progress;

  const StatusOverview({
    Key? key,
    required this.currentStep,
    required this.elapsedTime,
    required this.estimatedCompletion,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Process Status', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            _buildStatusRow('Current Step:', currentStep),
            _buildStatusRow('Elapsed Time:', elapsedTime),
            _buildStatusRow('ETA:', estimatedCompletion),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: ALDColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(ALDColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ALDColors.textLight)),
          Text(value, style: TextStyle(color: ALDColors.text, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}