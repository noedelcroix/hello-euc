import 'package:hello_euc/services/permission_service.dart';

enum Permissions {
  batteryOptimization,
  location;

  static Future<bool> valid(Permissions permission) async {
    switch (permission) {
      case Permissions.batteryOptimization:
        return await PermissionService().checkBatteryOptimization();
      case Permissions.location:
        return await PermissionService().checkLocationPermission();
    }
  }

  static Future<void> request(Permissions permission) async {
    switch (permission) {
      case Permissions.batteryOptimization:
        await PermissionService().requestBatteryOptimization();
        break;
      case Permissions.location:
        await PermissionService().requestLocationPermission();
        break;
    }
  }
}
