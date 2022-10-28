import 'package:flutter/material.dart';

import '../../pages/shared/shared_page.dart';
import '../../pages/start/start_page.dart';
import '../interface/route.dart';

class SharedRoutes {
  final GlobalKey<NavigatorState> globalKey;
  final List<PBPageRoute> routes = [];

  SharedRoutes(this.globalKey) {
    final _startRoute = PBPageRoute(
      name: StartPage.name,
      path: "",
      builder: (_, __) {
        return const StartPage();
      },
      parentNavigatorKey: globalKey,
    );

    final _sharedRoute = PBPageRoute(
      name: SharedPage.name,
      builder: (_, state) {
        return SharedPage(
          sharedObject:
              state.extra != null ? (state.extra as SharedObject?) : null,
        );
      },
      parentNavigatorKey: globalKey,
    );

    routes.add(_startRoute);
    routes.add(_sharedRoute);
  }
}
