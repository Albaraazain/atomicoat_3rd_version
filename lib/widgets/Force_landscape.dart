import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForceLandscape extends StatefulWidget {
  final Widget child;

  const ForceLandscape({Key? key, required this.child}) : super(key: key);

  @override
  _ForceLandscapeState createState() => _ForceLandscapeState();
}

class _ForceLandscapeState extends State<ForceLandscape> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}