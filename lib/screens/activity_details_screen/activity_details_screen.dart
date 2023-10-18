import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_euc/crud/activity_crud.dart';
import 'package:hello_euc/models/activity.dart';
import 'package:hello_euc/services/location_service.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> reccord;

  const ActivityDetailsScreen({super.key, required this.reccord});

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

  void _onMapCreated(MaplibreMapController controller) {
    mapController = controller;
    mapController.resizeWebMap();
    mapController.addGeoJsonSource("activity", widget.reccord);
    mapController.addLineLayer("activity", "activity",
        const LineLayerProperties(lineColor: "#ff0000", lineWidth: 3.0));

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
    setState(() {
      points = widget.reccord['features'][0]['geometry']['coordinates']
          .map((e) => LatLng(e[1], e[0]))
          .toList()
          .cast<LatLng>();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      brightness = View.of(context).platformDispatcher.platformBrightness;
    });

    return Scaffold(
        appBar: AppBar(
          title: const Text('Activity Details'),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("New Activity"),
                    TextFormField(
                      controller: _activityNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration:
                          const InputDecoration(hintText: "Activity Name"),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    LayoutBuilder(
                        builder: (context, constraints) => SizedBox.square(
                            dimension: constraints.maxWidth,
                            child: MaplibreMap(
                              initialCameraPosition: CameraPosition(
                                  target: points[points.length ~/ 2],
                                  zoom: 10.0),
                              styleString:
                                  'https://tiles.stadiamaps.com/styles/alidade_smooth${brightness == Brightness.dark ? '_dark' : ''}.json?api_key=${const String.fromEnvironment('STADIA_API_KEY')}',
                              onMapCreated: _onMapCreated,
                            ))),
                    ElevatedButton(
                        onPressed: () {
                          if (_form.currentState == null ||
                              !_form.currentState!.validate()) return;
                          GetIt.I<ActivityCrud>().insert(Activity(
                              _activityNameController.text, widget.reccord));
                          Navigator.pop(context);
                        },
                        child: const Text("Save"))
                  ],
                ))));
  }
}