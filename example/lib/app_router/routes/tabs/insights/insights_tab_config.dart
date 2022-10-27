import 'package:flutter/material.dart';

import '../../../interface/route.dart';
import 'insights_tab_routes.dart';

class InsightsTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  final InsightsTabRoutes _tabRoutes;
  late final PBTabRouteItem _tabItem;

  InsightsTabConfig() : _tabRoutes = InsightsTabRoutes() {
    _init();
  }

  PBTabRouteItem get tabItem => _tabItem;

  void _init() {
    _tabItem = PBTabRouteItem(
      baseRoute: _tabRoutes.baseRoute,
      iconData: Icons.article,
      name: "Insights",
      navigatorKey: _navigatorKey,
    );
  }
}
