import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  late SharedPreferences db;
  Map<String, dynamic>? settings;
  StreamController eventEmitter = StreamController();

  Settings();

  Future<void> init() async {
    db = await SharedPreferences.getInstance();
    String? data = db.getString("settings");
    settings = jsonDecode(data ?? "{}") as Map<String, dynamic>;
  }

  get(String key) {
    return settings?[key];
  }

  set(String key, dynamic value) {
    settings?[key] = value;
    db.setString("settings", json.encode(settings));
    eventEmitter.add({key: value});
  }

  onChange(Function callback) {
    eventEmitter.stream.listen((event) {
      callback();
    });
  }
}
