import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_euc/components/colorpick.dart';
import 'package:hello_euc/components/export.dart';
import 'package:hello_euc/components/gap.dart';
import 'package:hello_euc/components/statistics.dart';
import 'package:hello_euc/crud/activity_crud.dart';
import 'package:hello_euc/models/activity.dart';
import 'package:hello_euc/services/location_service.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  State<StatefulWidget> createState() {
    return _ActivityDetailsScreenState();
  }
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  Brightness? brightness;
  late MaplibreMapController mapController;
  List<LatLng> points = [];
  final _form = GlobalKey<FormState>();
  final TextEditingController _activityNameController = TextEditingController();
  late Activity activity;

  void _onMapCreated(MaplibreMapController controller) {
    mapController = controller;
  }

  void _onStyleLoaded() {
    mapController.resizeWebMap();
    mapController.addGeoJsonSource("activity", widget.activity.geojson);
    mapController.addLineLayer(
        "activity",
        "activity",
        LineLayerProperties(
            lineColor:
                "#${activity.color?.value.toRadixString(16).substring(2) ?? "ff0000"}",
            lineWidth: 3.0));

    List<LatLng> bounds = LocationService.getBounds(points);

    mapController.setCameraBounds(
        west: bounds[0].latitude,
        north: bounds[1].longitude,
        south: bounds[0].longitude,
        east: bounds[1].latitude,
        padding: 100);
  }

  @override
  void initState() {
    _activityNameController.text = widget.activity.name ?? "";
    setState(() {
      activity = widget.activity;
    });
    activity.color = widget.activity.color ?? Colors.blue;
    points = widget.activity.geojson['features'][0]['geometry']['coordinates']
        .map((e) => LatLng(e[1], e[0]))
        .toList()
        .cast<LatLng>();

    super.initState();
  }

  _onColorChanged(Color color) {
    setState(() {
      if (activity.name != null) {
        saveActivity();
      }
    });
    mapController.removeLayer("activity");
    mapController.addLineLayer(
        "activity",
        "activity",
        LineLayerProperties(
            lineColor:
                "#${activity.color?.value.toRadixString(16).substring(2) ?? "ff0000"}",
            lineWidth: 3.0));
  }

  saveActivity() {
    GetIt.I<ActivityCrud>().insert(Activity(
        _activityNameController.text, activity.color, activity.locations));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      brightness = View.of(context).platformDispatcher.platformBrightness;
    });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: activity.color ?? Colors.blue,
          title: Text(activity.name ?? "New Activity"),
        ),
        body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 30.0),
                    child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width: constraints.maxWidth * 0.60,
                                      child: TextFormField(
                                        readOnly: widget.activity.name != null,
                                        controller: _activityNameController,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        decoration: const InputDecoration(
                                            hintText: "Activity Name"),
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }

                                          if (GetIt.I<ActivityCrud>()
                                                  .getByName(value) !=
                                              null) {
                                            return 'Activity with this name already exists';
                                          }

                                          return null;
                                        },
                                      )),
                                  ColorPick(
                                      activity: activity,
                                      constraints: constraints,
                                      onColorChanged: _onColorChanged)
                                ]),
                            const Gap(),
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: constraints.maxWidth / 2),
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    child: MaplibreMap(
                                      initialCameraPosition: CameraPosition(
                                          target: points[points.length ~/ 2],
                                          zoom: 10.0),
                                      styleString:
                                          'https://tiles.stadiamaps.com/styles/alidade_smooth${brightness == Brightness.dark ? '_dark' : ''}.json?api_key=${const String.fromEnvironment('STADIA_API_KEY')}',
                                      onMapCreated: _onMapCreated,
                                      onStyleLoadedCallback: _onStyleLoaded,
                                    ))),
                            if (widget.activity.name == null)
                              ElevatedButton(
                                  onPressed: () {
                                    if (widget.activity.name != null ||
                                        _form.currentState == null ||
                                        !_form.currentState!.validate()) {
                                      return;
                                    }
                                    saveActivity();
                                    Get.back();
                                  },
                                  child: const Text("Save")),
                            Statistics(
                                constraints: constraints, activity: activity),
                            Export(activity: activity)
                          ],
                        ))))));
  }
}
