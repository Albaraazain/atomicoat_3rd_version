import 'package:flutter/material.dart';
import '../styles/theme.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onEmergencyStop;
  final VoidCallback onGenerateReport;
  final VoidCallback onCalibrate;

  const QuickActions({
    Key? key,
    required this.onEmergencyStop,
    required this.onGenerateReport,
    required this.onCalibrate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          'Emergency Stop',
          Icons.emergency,
          Colors.red,
          onEmergencyStop,
        ),
        _buildActionButton(
          context,
          'Generate Report',
          Icons.assessment,
          ALDColors.primary,
          onGenerateReport,
        ),
        _buildActionButton(
          context,
          'Calibrate',
          Icons.tune,
          Colors.orange,
          onCalibrate,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(label, style: TextStyle(fontSize: 12)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}