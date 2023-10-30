import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hello_euc/models/activity.dart';
import 'package:hello_euc/screens/activity_details_screen/activity_details_screen.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class LocationService {
  late Location location;
  LocationData? lastKnownLocation;
  Activity? currentActivity;

  LocationService() {
    location = Location();
    location.enableBackgroundMode(enable: true);
  }

  requestAll() async {
    await LocationService().requestPermissionInfinitly();
    await LocationService().requestEnableServiceOnce();
    return getServiceAvailability();
  }

  requestPermissionInfinitly() async {
    PermissionStatus permission = await location.hasPermission();
    while (permission == PermissionStatus.denied) {
      await location.requestPermission();
      permission = await location.hasPermission();
    }

    while (!await location.isBackgroundModeEnabled()) {
      await location.enableBackgroundMode(enable: true);
    }
  }

  requestEnableServiceOnce() async {
    await location.requestService();
  }

  getServiceAvailability() async {
    PermissionStatus permission = await location.hasPermission();
    return (permission == PermissionStatus.granted ||
            permission == PermissionStatus.grantedLimited) &&
        await location.serviceEnabled() &&
        await location.isBackgroundModeEnabled();
  }

  onLocationChanged(Function(LocationData) callback) {
    location.onLocationChanged.listen((LocationData currentLocation) {
      lastKnownLocation = currentLocation;
      if (currentActivity != null) {
        addStepToCurrentReccord(currentLocation);
      }
      callback(currentLocation);
    });
  }

  startRecording() async {
    currentActivity = Activity(null, null, []);

    if (lastKnownLocation != null) {
      addStepToCurrentReccord(lastKnownLocation!);
    }
  }

  addStepToCurrentReccord(LocationData currentLocation) {
    currentActivity?.addLocation(currentLocation);
  }

  Activity? getCurrentActivity() {
    return currentActivity;
  }

  Future<void> stopRecording(BuildContext context) async {
    if (currentActivity == null || currentActivity?.locations.isEmpty == true) {
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

  static double calculateDistance(LocationData pos1, LocationData pos2) {
    if (pos1.latitude == null ||
        pos1.longitude == null ||
        pos2.latitude == null ||
        pos2.longitude == null) {
      return 0;
    }
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((pos2.latitude! - pos1.latitude!) * p) / 2 +
        c(pos1.latitude! * p) *
            c(pos2.latitude! * p) *
            (1 - c((pos2.longitude! - pos1.longitude!) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  static double calculateTotalDistance(List<LocationData> locations) {
    double totalDistance = 0;
    for (int i = 0; i < locations.length - 1; i++) {
      totalDistance += calculateDistance(locations[i], locations[i + 1]);
    }
    return totalDistance;
  }

  static double calculateAltitudeDifference(List<LocationData> locations) {
    double minAltitude = locations[0].altitude!;
    double maxAltitude = locations[0].altitude!;

    for (var location in locations) {
      minAltitude =
          location.altitude! < minAltitude ? location.altitude! : minAltitude;
      maxAltitude =
          location.altitude! > maxAltitude ? location.altitude! : maxAltitude;
    }

    return maxAltitude - minAltitude;
  }
}
