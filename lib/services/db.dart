import 'package:flutter_gundb/flutter_gundb.dart';

class Db {
  FlutterGunSeaClient? client;
  Db() {
    client = FlutterGunSeaClient(registerStorage: true);
  }

  get(key) {
    return client?.getValue(key);
  }

  update(key, value) {
    client?.get(key).put(value);
  }
}
