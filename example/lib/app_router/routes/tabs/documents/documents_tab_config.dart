import 'package:flutter/material.dart';

import '../../../interface/route.dart';
import 'documents_tab_routes.dart';

class DocumentsTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  final DocumentsTabRoutes _tabRoutes;
  late final PBTabRouteItem _tabItem;

  DocumentsTabConfig() : _tabRoutes = DocumentsTabRoutes() {
    _init();
  }

  PBTabRouteItem get tabItem => _tabItem;

  void _init() {
    _tabItem = PBTabRouteItem(
      baseRoute: _tabRoutes.baseRoute,
      iconData: Icons.newspaper,
      name: "Documents",
      navigatorKey: _navigatorKey,
    );
  }
}
