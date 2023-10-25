import 'package:hello_euc/models/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class ActivityCrud {
  late SharedPreferences db;
  ActivityCrud();

  Future<void> init() async {
    db = await SharedPreferences.getInstance();
  }

  Future<void> insert(Activity activity) async {
    List<Activity> activities = getAll();
    activities.removeWhere((element) => element.name == activity.name);

    activities.add(activity);
    await db.setString("activities", activities.toString());
  }

  List<Activity> getAll() {
    String? data = db.getString("activities");
    return Activity.decode(data ?? "[]");
  }

  Future<void> remove(Activity activity) async {
    List<Activity> activities = getAll();
    activities.removeWhere((other) {
      return other.name == activity.name;
    });
    await db.setString("activities", activities.toString());
  }

  Activity? getByName(String name) {
    List<Activity> activities = getAll();
    return activities.firstWhereOrNull((element) => element.name == name);
  }
}
