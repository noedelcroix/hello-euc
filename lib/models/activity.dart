import 'dart:convert';
import 'dart:ui';

import 'package:hello_euc/models/enums/export_type.dart';
import 'package:location/location.dart';

class Activity {
  final String? name;
  Color? color;
  final List<LocationData> locations;

  Activity(this.name, this.color, this.locations);

  static List<Activity> decode(String data) {
    List<Activity> activities = [];
    List<dynamic> decodedData = json.decode(data);
    for (var item in decodedData) {
      activities.add(Activity(
          item['name'],
          Color(int.parse(item['color'] ?? 'ff000000', radix: 16)),
          (item['locations'] as List)
              .map((e) => LocationData.fromMap(e))
              .toList()));
    }
    return activities;
  }

  @override
  String toString() {
    Map<String, dynamic> data = {
      'name': name,
      'locations': [],
      'color': color?.value.toRadixString(16)
    };
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

  get kml {
    String kmlData = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>$name</name>
    <Style id="style">
      <LineStyle>
        <color>${color?.value.toRadixString(16) ?? "ff000000"}</color>
        <width>4</width>
      </LineStyle>
    </Style>
    <Placemark>
      <name>$name</name>
      <styleUrl>#style</styleUrl>
      <LineString>
        <tessellate>1</tessellate>
        <coordinates>
        ${locations.map((position) => "${position.longitude},${position.latitude},${position.altitude?.toInt() ?? 1}").join('\n')}
        </coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>
''';

    return kmlData;
  }

  getFileContent(ExportType type) {
    switch (type) {
      case ExportType.geojson:
        return json.encode(geojson);
      case ExportType.kml:
        return kml;
      default:
        return toString();
    }
  }

  addLocation(LocationData location) {
    locations.add(location);
  }
}
