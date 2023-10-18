import 'package:flutter/material.dart';

class WheelSettingsScreen extends StatefulWidget {
  static const String routeName = "/wheel-settings-screen";

  const WheelSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WheelSettingsScreenState();
}

class _WheelSettingsScreenState extends State<WheelSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wheel Settings"),
      ),
      body: const Center(
        child: Text("Wheel Settings"),
      ),
    );
  }
}
