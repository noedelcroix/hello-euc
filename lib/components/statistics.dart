import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:hello_euc/components/gap.dart';
import 'package:hello_euc/components/styled_title.dart';
import 'package:hello_euc/models/activity.dart';
import 'package:hello_euc/services/location_service.dart';
import 'package:intl/intl.dart';

class Statistics extends StatefulWidget {
  final BoxConstraints constraints;
  final Activity activity;

  const Statistics(
      {super.key, required this.constraints, required this.activity});

  @override
  State<StatefulWidget> createState() {
    return _StatisticsState();
  }
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Text("Distance"),
              Text(
                  "${(LocationService.calculateTotalDistance(widget.activity.locations)).toStringAsFixed(2)} km")
            ],
          ),
          Column(
            children: [
              const Text("Duration"),
              Text(Activity.computeDuration(
                      widget.activity.locations[0],
                      widget.activity
                          .locations[widget.activity.locations.length - 1])
                  .toString()
                  .split(".")[0])
            ],
          ),
          Column(children: [
            const Text("Altitude"),
            Text(
                "${LocationService.calculateAltitudeDifference(widget.activity.locations).toInt()}m")
          ])
        ],
      ),
      StyledTitle(
          title: "Speed", constraints: widget.constraints, color: Colors.black),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(children: [
          const Text("Max speed"),
          Text("${widget.activity.maxSpeed} km/h")
        ]),
        Column(children: [
          const Text("Average speed"),
          Text("${widget.activity.averageSpeed} km/h")
        ]),
      ]),
      SizedBox(
          height: widget.constraints.maxWidth / 2,
          child: Chart(
            data: widget.activity.locations
                .map((e) =>
                    {'speed': ((e.speed ?? 0) * 3.6).toInt(), 'time': e.time})
                .toList(),
            variables: {
              'time': Variable(
                  accessor: (Map map) =>
                      DateTime.fromMillisecondsSinceEpoch(map['time'].toInt()),
                  scale: TimeScale(
                      formatter: (time) => DateFormat.Hms().format(time))),
              'speed': Variable(accessor: (Map map) => map['speed'] as num),
            },
            axes: [
              Defaults.horizontalAxis,
              Defaults.verticalAxis,
            ],
            marks: [LineMark(color: ColorEncode(value: widget.activity.color))],
          )),
      const Gap(),
      StyledTitle(
        title: "Altitude",
        constraints: widget.constraints,
        color: Colors.black,
      ),
      SizedBox(
          height: widget.constraints.maxWidth / 2,
          child: Chart(
            data: widget.activity.locations
                .asMap()
                .entries
                .map((entry) => {
                      'altitude': entry.value.altitude ?? 0,
                      'distance': LocationService.calculateTotalDistance(
                          widget.activity.locations.sublist(0, entry.key + 1))
                    })
                .toList(),
            variables: {
              'distance':
                  Variable(accessor: (Map map) => map['distance'] as num),
              'altitude':
                  Variable(accessor: (Map map) => map['altitude'] as num),
            },
            axes: [
              Defaults.horizontalAxis,
              Defaults.verticalAxis,
            ],
            marks: [LineMark(color: ColorEncode(value: widget.activity.color))],
          )),
    ]);
  }
}
