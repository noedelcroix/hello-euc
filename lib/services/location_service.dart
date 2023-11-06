import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hello_euc/models/activity.dart';
import 'package:hello_euc/screens/activity_details_screen/activity_details_screen.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:optimize_battery/optimize_battery.dart';

class LocationService {
  Activity? currentActivity;

  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    while (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  Future<bool> requestEnableServiceOnce() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  requestBatteryOptimization() async {
    bool r = await OptimizeBattery.isIgnoringBatteryOptimizations();
    while (!r) {
      r = await OptimizeBattery.stopOptimizingBatteryUsage();
    }
  }

  onLocationChanged(Function(Position) callback) {
    Geolocator.getPositionStream().listen((Position position) {
      addStepToCurrentReccord(position);
      callback(position);
    });
  }

  startRecording() async {
    currentActivity = Activity(null, null, []);
    var lastKnownLocation = await Geolocator.getLastKnownPosition();

    if (lastKnownLocation != null) {
      addStepToCurrentReccord(lastKnownLocation);
    }
  }

  addStepToCurrentReccord(Position currentLocation) {
    currentActivity?.addLocation(currentLocation);
  }

  Activity? getCurrentActivity() {
    return currentActivity;
  }

  Future<void> stopRecording(BuildContext context) async {
    if (currentActivity == null) {
      return;
    }

    if (currentActivity?.locations.isEmpty == true) {
      currentActivity = null;
      return;
    }

    Activity activity = currentActivity!;
    currentActivity = null;

    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ActivityDetailsScreen(
                activity: activity,
              )),
    );
  }

  static List<LatLng> getBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return [];
    }
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    return [LatLng(minLng, minLat), LatLng(maxLng, maxLat)];
  }

  static double calculateDistance(Position pos1, Position pos2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((pos2.latitude - pos1.latitude) * p) / 2 +
        c(pos1.latitude * p) *
            c(pos2.latitude * p) *
            (1 - c((pos2.longitude - pos1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  static double calculateTotalDistance(List<Position> locations) {
    double totalDistance = 0;
    for (int i = 0; i < locations.length - 1; i++) {
      totalDistance += calculateDistance(locations[i], locations[i + 1]);
    }
    return totalDistance;
  }

  static double calculateAltitudeDifference(List<Position> locations) {
    double minAltitude = locations[0].altitude;
    double maxAltitude = locations[0].altitude;

    for (var location in locations) {
      minAltitude =
          location.altitude < minAltitude ? location.altitude : minAltitude;
      maxAltitude =
          location.altitude > maxAltitude ? location.altitude : maxAltitude;
    }

    return maxAltitude - minAltitude;
  }
}
