import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hello_euc/services/permission_service.dart';

class PermissionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return route == '/permission_request' ||
            !PermissionService.to.lastStatePermission.values
                .map((e) => e.value)
                .contains(false)
        ? null
        : const RouteSettings(name: '/permission_request');
  }
}
