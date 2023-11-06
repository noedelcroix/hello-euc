import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hello_euc/models/enums/permissions.dart';
import 'package:optimize_battery/optimize_battery.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends GetxService {
  Map<Permissions, RxBool> lastStatePermission = {
    Permissions.batteryOptimization: false.obs,
    Permissions.location: false.obs
  };

  static PermissionService get to => Get.find();

  Future<PermissionService> init() async {
    Timer.periodic(const Duration(milliseconds: 10), (timeStamp) {
      checkBatteryOptimization().then((value) {
        if (value !=
            lastStatePermission[Permissions.batteryOptimization]?.value) {
          lastStatePermission[Permissions.batteryOptimization]?.value = value;
        }
      });

      checkLocationPermission().then((value) {
        if (value != lastStatePermission[Permissions.location]?.value) {
          lastStatePermission[Permissions.location]?.value = value;
        }
      });

      all().then((value) {
        if (value) {
          Get.back();
        }
      });
    });

    return this;
  }

  Future<bool> all() async {
    return await checkBatteryOptimization() && await checkLocationPermission();
  }

  Future<bool> checkBatteryOptimization() async {
    return await OptimizeBattery.isIgnoringBatteryOptimizations();
  }

  Future<bool> checkLocationPermission() async {
    return await Geolocator.checkPermission() == LocationPermission.always;
  }

  Future<bool> requestBatteryOptimization() async {
    if (!await OptimizeBattery.isIgnoringBatteryOptimizations()) {
      await OptimizeBattery.stopOptimizingBatteryUsage();
      return await OptimizeBattery.isIgnoringBatteryOptimizations();
    }

    return true;
  }

  Future<LocationPermission> requestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    while (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    while (permission != LocationPermission.always) {
      await Permission.locationAlways.request();
      permission = await Geolocator.checkPermission();
    }

    return permission;
  }
}
