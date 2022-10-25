import 'package:flutter/material.dart' show Icons, GlobalKey, NavigatorState;


import '../../pages/home/documents/documents_page.dart';
import '../app_route.dart';

class DocumentsTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  late final TabRouteItem _tabItem;
  TabRouteItem get tabItem => _tabItem;

  DocumentsTabConfig() {
    _init();
  }

  void _init() {
    _tabItem = TabRouteItem(
      baseRoute: _documentsRoute,
      iconData: Icons.newspaper,
      name: "Documents",
      navigatorKey: _navigatorKey,
    );
  }

  final _documentsRoute = PageRoute(
    name: "documents",
    builder: (context, state) {
      return const DocumentsPage();
    },
  );
}
