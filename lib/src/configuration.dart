import 'package:flutter/material.dart';

import 'location.dart';
import 'route.dart';
import 'router_exception.dart';
import 'utils.dart';

class AppRouterConfiguration {
  final List<BaseAppRoute> topLevelRoutes;
  final GlobalKey<NavigatorState> globalNavigatorKey;
  final Map<String, String> _nameToPathMap = <String, String>{};

  AppRouterConfiguration({
    required this.topLevelRoutes,
    required this.globalNavigatorKey,
  }) {
    createNamedMap(parentFullPath: '', routes: topLevelRoutes);
  }

  Map<String, String> get nameToPathMap => _nameToPathMap;

  @visibleForTesting
  void createNamedMap({
    required String parentFullPath,
    required List<BaseAppRoute> routes,
  }) {
    for (final route in routes) {
      if (route is AppPageRoute) {
        final String fullPath = PathUtils.joinPaths(parentFullPath, route.path);
        final String lowerCasedName = route.name.toLowerCase();
        assert(
          !_nameToPathMap.containsKey(lowerCasedName),
          'duplication fullpaths for name '
          '"$lowerCasedName":${_nameToPathMap[lowerCasedName]}, $fullPath',
        );
        _nameToPathMap[lowerCasedName] = fullPath;
        if (route.routes.isNotEmpty) {
          createNamedMap(parentFullPath: fullPath, routes: route.routes);
        }
      } else if (route is ShellRouteBase) {
        createNamedMap(parentFullPath: parentFullPath, routes: route.routes);
      }
    }
  }

  String getFullPathForName(String name) {
    final String lowerCasedName = name.toLowerCase();
    final path = _nameToPathMap[lowerCasedName];
    if (path == null) {
      throw AppRouterException("Unknown route name: $name");
    }
    return path;
  }

  AppRouterLocation locationForRoute(BaseAppRoute route) {
    return _locationForRoute(route, '', topLevelRoutes) ??
        const AppRouterLocation.empty();
  }

  static AppRouterLocation? _locationForRoute(
    BaseAppRoute targetRoute,
    String parentFullpath,
    List<BaseAppRoute> routes,
  ) {
    for (final route in routes) {
      final String fullPath = (route is AppPageRoute)
          ? PathUtils.joinPaths(parentFullpath, route.path)
          : parentFullpath;

      if (route == targetRoute) {
        return AppRouterLocation(path: fullPath, name: route.name);
      } else {
        final AppRouterLocation? subRoutePath = _locationForRoute(
          targetRoute,
          fullPath,
          route.routes,
        );
        if (subRoutePath != null) {
          return subRoutePath;
        }
      }
    }
    return null;
  }
}
