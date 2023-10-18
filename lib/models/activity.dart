import 'dart:convert';

class Activity {
  final String name;
  final Map<String, dynamic> geojson;

  Activity(this.name, this.geojson);

  static List<Activity> decode(String data) {
    List<Activity> activities = [];
    List<dynamic> decodedData = json.decode(data);
    for (var item in decodedData) {
      activities.add(Activity(item['name'], item['geojson']));
    }
    return activities;
  }

  @override
  String toString() {
    return json.encode({'name': name, 'geojson': geojson});
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity &&
          name == other.name &&
          geojson.toString() == other.geojson.toString();

  @override
  int get hashCode => Object.hash(name, geojson);
}
