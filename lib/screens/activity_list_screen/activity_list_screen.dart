import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_euc/crud/activity_crud.dart';
import 'package:hello_euc/models/activity.dart';

class ActivityListScreen extends StatefulWidget {
  static const String routeName = "/activity-list-screen";

  const ActivityListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  List<Activity> activities = [];

  @override
  void initState() {
    GetIt.I<ActivityCrud>().getAll().then((activities) => setState(() {
          this.activities = activities;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Activity List"),
        ),
        body: activities.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(activities[index].name),
                    trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await GetIt.I<ActivityCrud>()
                              .remove(activities[index]);
                          GetIt.I<ActivityCrud>()
                              .getAll()
                              .then((activities) => setState(() {
                                    this.activities = activities;
                                  }));
                        }),
                  );
                },
                itemCount: activities.length,
              )
            : const Center(
                child: Text("No activities"),
              ));
  }
}
