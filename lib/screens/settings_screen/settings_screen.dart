import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_euc/services/settings.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  Settings settings = GetIt.I<Settings>();
  @override
  void initState() {
    settings.init().then((value) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Map'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                  initialValue: settings.get("littleThumb"),
                  onToggle: (value) {
                    setState(() => settings.set("littleThumb", value));
                  },
                  title: const Text("Enable Little Thumb")),
              SettingsTile.navigation(
                  title: const Text("Clear little thumb"),
                  leading: const Icon(Icons.delete),
                  onPressed: (context) async {
                    await settings.clearLittleThumb();
                    setState(() {});
                  })
            ],
          ),
        ],
      ),
    );
  }
}
