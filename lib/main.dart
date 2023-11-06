import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_euc/crud/activity_crud.dart';
import 'package:hello_euc/middlewares/permission_middleware.dart';
import 'package:hello_euc/screens/activity_list_screen/activity_list_screen.dart';
import 'package:hello_euc/screens/map_screen/map_screen.dart';
import 'package:hello_euc/screens/permission_request/permission_request.dart';
import 'package:hello_euc/screens/settings_screen/settings_screen.dart';
import 'package:hello_euc/screens/wheel_settings_screen/wheel_settings_screen.dart';
import 'package:hello_euc/services/location_service.dart';
import 'package:hello_euc/services/permission_service.dart';
import 'package:hello_euc/services/settings.dart';
import 'package:flutter_gundb/flutter_gundb.dart';

initializeSingletions() async {
  await GetIt.I.registerSingleton<Settings>(Settings()).init();
  GetIt.I.registerSingleton<LocationService>(LocationService());
  await GetIt.I.registerSingleton<ActivityCrud>(ActivityCrud()).init();
  Get.put(PermissionService());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSingletions();
  await initializeFlutterGun();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(GetMaterialApp(
            title: 'Hello EUC',
            debugShowCheckedModeBanner: false,
            home: const App(),
            getPages: [
              GetPage(name: '/app', page: () => const App(), middlewares: [
                PermissionMiddleware(),
              ]),
              GetPage(
                  name: '/permission_request',
                  page: () => const PermissionRequest(),
                  middlewares: [
                    PermissionMiddleware(),
                  ])
            ],
          )));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  bool allPermissions = false;

  @override
  void initState() {
    Timer.periodic(
        const Duration(milliseconds: 10),
        (timestamp) => PermissionService()
            .all()
            .then((value) => setState(() => allPermissions = value)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return allPermissions
        ? DefaultTabController(
            length: 4,
            child: Scaffold(
              body: const TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    MapScreen(),
                    WheelSettingsScreen(),
                    ActivityListScreen(),
                    SettingsScreen()
                  ]),
              backgroundColor: Colors.blue,
              bottomNavigationBar: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.map)),
                  Tab(icon: Icon(Icons.settings_bluetooth)),
                  Tab(icon: Icon(Icons.list)),
                  Tab(icon: Icon(Icons.settings))
                ],
                labelColor: Colors.white,
              ),
              floatingActionButton: FloatingActionButton(
                  heroTag: null,
                  foregroundColor: Colors.redAccent,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      GetIt.I<LocationService>().getCurrentActivity() == null
                          ? GetIt.I<LocationService>().startRecording()
                          : GetIt.I<LocationService>().stopRecording(context);
                    });
                  },
                  child: Icon(
                      GetIt.I<LocationService>().getCurrentActivity() == null
                          ? Icons.radio_button_checked
                          : Icons.square)),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            ))
        : const PermissionRequest();
  }
}
