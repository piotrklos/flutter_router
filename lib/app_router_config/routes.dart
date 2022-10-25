import 'package:flutter/material.dart' show BuildContext;

import '../pages/shared/shared_page.dart';
import '../pages/start/start_page.dart';
import 'app_route.dart';
import 'app_router_config.dart';
import 'router_page_state.dart';

class PageRoutes {
  static final startRoute = PageRoute(
    name: "start",
    path: "",
    builder: (BuildContext context, RouterPageState state) {
      return const StartPage();
    },
    parentNavigatorKey: AppRouterConfig.globalNavigationKey,
  );

  static final sharedRoute = PageRoute(
    name: "shared",
    builder: (BuildContext context, RouterPageState state) {
      return SharedPage(
        sharedObject:
            state.extra != null ? (state.extra as SharedObject?) : null,
      );
    },
    parentNavigatorKey: AppRouterConfig.globalNavigationKey,
  );
}
