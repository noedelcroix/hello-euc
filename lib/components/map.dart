import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_euc/services/location_service.dart';
import 'package:hello_euc/services/settings.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapComponent extends StatefulWidget {
  final Function notifySpeed;

  const MapComponent({super.key, required this.notifySpeed});

  @override
  State<StatefulWidget> createState() {
    return _MapComponentState();
  }
}

class _MapComponentState extends State<MapComponent>
    with AutomaticKeepAliveClientMixin<MapComponent> {
  late MaplibreMapController mapController;
  late Brightness brightness;
  bool trackCompassEnabled = false;
  bool trackLocationEnabled = false;
  bool locationEnabled = false;
  bool lock = false;
  Settings settings = GetIt.I<Settings>();
  late SharedPreferences db;
  late Map<String, dynamic> littleThumbPoints = {
    "type": "FeatureCollection",
    "features": []
  };
  final LocationService locationService = GetIt.I<LocationService>();

  Icon _getIcon() {
    return Icon(locationEnabled
        ? trackCompassEnabled
            ? Icons.explore
            : trackLocationEnabled
                ? Icons.my_location_outlined
                : Icons.location_searching
        : Icons.location_disabled);
  }

  void _toggleTracking() async {
    lock = true;
    if (!await Geolocator.isLocationServiceEnabled()) {
      lock = false;
      return;
    }

    await mapController.animateCamera(CameraUpdate.zoomTo(16.0),
        duration: const Duration(milliseconds: 500));

    if (trackLocationEnabled && !trackCompassEnabled) {
      await mapController.animateCamera(CameraUpdate.tiltTo(80.0),
          duration: const Duration(milliseconds: 100));
    } else {
      await mapController.animateCamera(CameraUpdate.tiltTo(0.0),
          duration: const Duration(milliseconds: 100));
      await mapController.animateCamera(CameraUpdate.bearingTo(0.0),
          duration: const Duration(milliseconds: 500));
    }

    setState(() {
      trackCompassEnabled = trackLocationEnabled ? !trackCompassEnabled : false;
      trackLocationEnabled = true;
    });

    lock = false;
  }

  void _onMapCreated(MaplibreMapController controller) async {
    mapController = controller;
    db = await SharedPreferences.getInstance();
  }

  void _onStyleLoaded() async {
    await _littleThumbInit();
    locationService.onLocationChanged(_littleThumb);
  }

  Future<void> _littleThumbInit() async {
    String? data = db.get('littleThumb') as String?;

    if (data != null) {
      setState(() {
        littleThumbPoints = json.decode(data);
      });
    }

    updateLayer(
        'littleThumb',
        littleThumbPoints,
        const SymbolLayerProperties(
            iconImage: 'assets/images/little_thumb.png', iconSize: 0.1));
  }

  void _littleThumb(Position location) async {
    updateLayer('currentReccord', locationService.getCurrentActivity()?.geojson,
        const LineLayerProperties(lineColor: '#007AFF', lineWidth: 4));

    if (settings.get('littleThumb') == null || !settings.get('littleThumb')) {
      return;
    }

    littleThumbPoints['features'].add({
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [location.longitude, location.latitude]
      }
    });

    db.setString('littleThumb', json.encode(littleThumbPoints));

    updateLayer(
        'littleThumb',
        littleThumbPoints,
        const SymbolLayerProperties(
            iconImage: 'assets/images/little_thumb.png', iconSize: 0.1));
  }

  updateLayer(String layerId, Map<String, dynamic>? geojson,
      LayerProperties props) async {
    if (geojson == null &&
        (await mapController.getLayerIds()).contains(layerId)) {
      await mapController.removeLayer(layerId);
      await mapController.removeSource(layerId);
      return;
    } else if (geojson == null) {
      return;
    }

    if ((await mapController.getSourceIds()).contains(layerId)) {
      mapController.setGeoJsonSource(layerId, geojson);
    } else {
      await mapController.addGeoJsonSource(layerId, geojson);
    }

    if (!(await mapController.getLayerIds()).contains(layerId)) {
      if (props is SymbolLayerProperties) {
        await mapController.addSymbolLayer(layerId, layerId, props);
      } else if (props is LineLayerProperties) {
        await mapController.addLineLayer(layerId, layerId, props);
      }
    }
  }

  @override
  void initState() {
    settings.init().then((value) => setState(() {}));
    settings.onChange((Map e) {
      if (e.containsKey('clearLittleThumb')) {
        setState(() {
          littleThumbPoints = {"type": "FeatureCollection", "features": []};
        });

        _littleThumbInit();
      } else {
        setState(() {});
        mapController.setLayerVisibility(
            'littleThumb', settings.get('littleThumb'));
      }
    });
    locationService.requestEnableServiceOnce();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    setState(() {
      brightness = View.of(context).platformDispatcher.platformBrightness;
    });

    locationService.requestEnableServiceOnce().then((value) {
      if (!mounted) return;
      setState(() {
        locationEnabled = value;
      });

      if (!value) {
        widget.notifySpeed(0.0);
      }
    });

    return Scaffold(
        body: MaplibreMap(
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoaded,
          initialCameraPosition:
              const CameraPosition(target: LatLng(0.0, 0.0), zoom: 0.0),
          styleString:
              'https://tiles.stadiamaps.com/styles/alidade_smooth${brightness == Brightness.dark ? '_dark' : ''}.json?api_key=${const String.fromEnvironment('STADIA_API_KEY')}',
          myLocationEnabled: locationEnabled,
          myLocationRenderMode: locationEnabled
              ? MyLocationRenderMode.GPS
              : MyLocationRenderMode.NORMAL,
          myLocationTrackingMode: trackCompassEnabled
              ? MyLocationTrackingMode.TrackingGPS
              : trackLocationEnabled
                  ? MyLocationTrackingMode.Tracking
                  : MyLocationTrackingMode.None,
          onUserLocationUpdated: (location) {
            widget.notifySpeed((location.speed ?? 0.0) * 3.6);
          },
          onCameraTrackingDismissed: () {
            if (lock) return;
            setState(() {
              trackLocationEnabled = false;
              trackCompassEnabled = false;
            });
          },
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => _toggleTracking(), child: _getIcon()));
  }

  @override
  bool get wantKeepAlive => true;
}
