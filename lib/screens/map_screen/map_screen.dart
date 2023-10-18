import 'package:flutter/material.dart';
import 'package:hello_euc/components/map.dart';
import 'package:hello_euc/components/speed_display.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  double speed = 0;

  void _speedCallback(double speed) {
    setState(() {
      this.speed = speed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      MapComponent(notifySpeed: _speedCallback),
      SpeedDisplay(speed: speed)
    ]));
  }
}
