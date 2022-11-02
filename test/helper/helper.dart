import 'package:app_router/route.dart';
import 'package:app_router/route_finder.dart';
import 'package:flutter/material.dart';

class TestHelper {
  static RouterPaths createRouterPaths(
    List<BaseAppRoute> routes,
  ) {
    if (routes.isEmpty) {
      return RouterPaths.empty();
    }

    String fullPath = "";

    final foundsRoutes = routes.map((route) {
      if (route is AppPageRoute) {
        fullPath = fullPath + "/" + route.name;
      }
      final foundRoute = FoundRoute.test(
        route: route,
        fullPath: fullPath,
      );
      return foundRoute;
    }).toList();

    return RouterPaths(foundsRoutes);
  }
}

class TestPageRoute {
  final String name;
  final bool isAppPage;
  final VoidCallback? onPop;
  final VoidCallback? onPush;

  TestPageRoute({
    required this.name,
    this.isAppPage = true,
    this.onPop,
    this.onPush,
  });

  BaseAppRoute appRoute({
    List<BaseAppRoute> routes = const [],
  }) {
    if (isAppPage) {
      return AppPageRoute(
        path: name,
        name: name,
        builder: (_, __) => Container(),
        onPop: onPop,
        onPush: onPush,
        routes: routes,
      );
    }
    return ShellRoute(
      builder: (context, state, child) {
        return Container();
      },
      routes: routes,
      onPop: onPop,
    );
  }
}

class MockFoundRoute extends FoundRoute {
  MockFoundRoute(
    String name, {
    VoidCallback? onPop,
    VoidCallback? onPush,
  }) : super.test(
          route: AppPageRoute(
            path: name,
            name: name,
            builder: (_, __) => Container(),
            onPop: onPop,
            onPush: onPush,
          ),
          fullPath: "/$name",
        );
}
