import 'package:flutter/material.dart';

class SpeedDisplay extends StatefulWidget {
  final double speed;
  const SpeedDisplay({super.key, required this.speed});

  @override
  State<StatefulWidget> createState() {
    return _SpeedDisplayState();
  }
}

class _SpeedDisplayState extends State<SpeedDisplay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 50,
        right: 15,
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 5),
                borderRadius: BorderRadius.circular(50),
                color: Colors.white),
            width: 75,
            height: 75,
            child: Text(
              '${(widget.speed).round()} \n km/h',
              textAlign: TextAlign.center,
            )));
  }
}
