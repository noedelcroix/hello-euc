import 'dart:convert';

import 'package:location/location.dart';

class Activity {
  final String? name;
  final List<LocationData> locations;

  Activity(this.name, this.locations);

  static List<Activity> decode(String data) {
    List<Activity> activities = [];
    List<dynamic> decodedData = json.decode(data);
    for (var item in decodedData) {
      activities.add(Activity(
          item['name'],
          (item['locations'] as List)
              .map((e) => LocationData.fromMap(e))
              .toList()));
    }
    return activities;
  }

  @override
  String toString() {
    Map<String, dynamic> data = {'name': name, 'locations': []};
    for (LocationData location in locations) {
      data['locations'].add({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'speed': location.speed,
        'heading': location.heading,
        'time': location.time
      });
    }

    return json.encode(data);
  }

  get geojson {
    Map<String, dynamic> geojsonData = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {"type": "LineString", "coordinates": []}
        }
      ]
    };

    for (var location in locations) {
      geojsonData['features'][0]['geometry']['coordinates']
          .add([location.longitude, location.latitude]);
    }

    return geojsonData;
  }

  addLocation(LocationData location) {
    locations.add(location);
  }
}
