import 'package:hello_euc/models/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityCrud {
  late SharedPreferences db;
  ActivityCrud();

  Future<void> init() async {
    db = await SharedPreferences.getInstance();
  }

  Future<void> insert(Activity activity) async {
    List<Activity> activities = await getAll();
    activities.add(activity);
    await db.setString("activities", activities.toString());
  }

  Future<List<Activity>> getAll() async {
    String? data = db.getString("activities");
    return Activity.decode(data ?? "[]");
  }

  Future<void> remove(Activity activity) async {
    List<Activity> activities = await getAll();
    activities.removeWhere((other) {
      return other == activity;
    });
    await db.setString("activities", activities.toString());
  }
}
