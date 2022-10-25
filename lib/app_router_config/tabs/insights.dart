import 'package:flutter/material.dart' show Icons, GlobalKey, NavigatorState;


import '../../pages/home/insights/insights_page.dart';
import '../app_route.dart';

class InsightsTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  late final TabRouteItem _tabItem;
  TabRouteItem get tabItem => _tabItem;

  InsightsTabConfig() {
    _init();
  }

  void _init() {
    _tabItem = TabRouteItem(
      baseRoute: _insightsRoute,
      iconData: Icons.article,
      name: "Insights",
      navigatorKey: _navigatorKey,
    );
  }

  final _insightsRoute = PageRoute(
    name: "insihgts",
    builder: (context, state) {
      return const InsightsPage();
    },
  );
}
