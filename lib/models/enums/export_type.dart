enum ExportType implements Comparable<ExportType> {
  geojson("GeoJSON", "geojson"),
  gpx("GPX", "gpx"),
  kml("KML", "kml"),
  csv("CSV", "csv");

  const ExportType(this.name, this.extension);

  final String name;
  final String extension;

  @override
  int compareTo(ExportType other) => name.compareTo(other.name);

  @override
  String toString() => name;
}
