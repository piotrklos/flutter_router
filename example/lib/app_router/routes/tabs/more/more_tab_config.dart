import 'package:flutter/material.dart';

import '../../../interface/route.dart';
import 'more_tab_routes.dart';

class MoreTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  final MoreTabRoutes _tabRoutes;
  late final PBTabRouteItem _tabItem;

  MoreTabConfig() : _tabRoutes = MoreTabRoutes() {
    _init();
  }

  PBTabRouteItem get tabItem => _tabItem;

  void _init() {
    _tabItem = PBTabRouteItem(
      baseRoute: _tabRoutes.baseRoute,
      iconData: Icons.more_horiz,
      name: "More",
      navigatorKey: _navigatorKey,
    );
  }
}
