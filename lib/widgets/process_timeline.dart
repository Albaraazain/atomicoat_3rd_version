import 'package:flutter/material.dart';
import '../styles/theme.dart';

class ProcessStep {
  final String name;
  final String status;
  final Duration duration;

  ProcessStep({required this.name, required this.status, required this.duration});
}

class ProcessTimeline extends StatelessWidget {
  final List<ProcessStep> steps;
  final int currentStepIndex;
  final Function(int) onStepTap;

  const ProcessTimeline({
    Key? key,
    required this.steps,
    required this.currentStepIndex,
    required this.onStepTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Process Timeline', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            for (int i = 0; i < steps.length; i++)
              _buildTimelineStep(context, i, steps[i]),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(BuildContext context, int index, ProcessStep step) {
    final isCompleted = index < currentStepIndex;
    final isCurrent = index == currentStepIndex;

    return InkWell(
      onTap: () => onStepTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? ALDColors.primary : (isCurrent ? ALDColors.accent : ALDColors.divider),
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.name,
                    style: TextStyle(
                      color: isCurrent ? ALDColors.text : ALDColors.textLight,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${step.status} - ${_formatDuration(step.duration)}',
                    style: TextStyle(
                      color: ALDColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ALDColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'In Progress',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}