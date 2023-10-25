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
    if (currentActivity == null) {
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
}
