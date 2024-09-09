import 'package:flutter/material.dart';
import '../styles/theme.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onStop;
  final VoidCallback? onReset;

  const ControlPanel({
    Key? key,
    this.onStart,
    this.onPause,
    this.onStop,
    this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Control Panel', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildControlButton('Start', Icons.play_arrow, Colors.green, onStart)),
                SizedBox(width: 8),
                Expanded(child: _buildControlButton('Pause', Icons.pause, Colors.orange, onPause)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildControlButton('Stop', Icons.stop, Colors.red, onStop)),
                SizedBox(width: 8),
                Expanded(child: _buildControlButton('Reset', Icons.refresh, Colors.blue, onReset)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, Color color, VoidCallback? onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.3),
        disabledForegroundColor: Colors.white60,
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}