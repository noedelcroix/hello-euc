import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hello_euc/components/styled_title.dart';
import 'package:hello_euc/models/enums/permissions.dart';
import 'package:hello_euc/services/permission_service.dart';

class PermissionRequest extends StatefulWidget {
  const PermissionRequest({super.key});

  @override
  State<StatefulWidget> createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
  static getIcon(bool val) {
    return val ? const Icon(Icons.check) : const Icon(Icons.close);
  }

  Widget getButton(Permissions permission) {
    return ElevatedButton(
      onPressed:
          PermissionService.to.lastStatePermission[permission]?.value == false
              ? () async {
                  await Permissions.request(permission);
                }
              : null,
      child: getIcon(
          PermissionService.to.lastStatePermission[permission]?.value == true),
      style: ElevatedButton.styleFrom(
          backgroundColor:
              PermissionService.to.lastStatePermission[permission]?.value ==
                      true
                  ? Colors.green
                  : Colors.red),
    );
  }

  @override
  void initState() {
    Timer.periodic(const Duration(milliseconds: 10), (timeStamp) {
      PermissionService().checkBatteryOptimization().then((value) {
        if (value !=
            PermissionService.to
                .lastStatePermission[Permissions.batteryOptimization]?.value) {
          PermissionService
              .to
              .lastStatePermission[Permissions.batteryOptimization]
              ?.value = value;
          setState(() {});
        }
      });

      PermissionService().checkLocationPermission().then((value) {
        if (value !=
            PermissionService
                .to.lastStatePermission[Permissions.location]?.value) {
          PermissionService
              .to.lastStatePermission[Permissions.location]?.value = value;
          setState(() {});
        }
      });

      PermissionService().all().then((value) {
        if (value) {
          Get.back();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
                builder: (context, constraints) => Column(children: [
                      StyledTitle(
                          title: "Required Permissions",
                          constraints: constraints),
                      Row(
                        children: [
                          const Text("Allow location permission : "),
                          getButton(Permissions.location)
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Disable Battery Optimization : "),
                          getButton(Permissions.batteryOptimization)
                        ],
                      )
                    ]))));
  }
}
