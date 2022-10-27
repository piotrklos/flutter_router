import 'package:flutter/material.dart';

import 'route.dart';
import 'router_exception.dart';
import 'typedef.dart';
import 'utils.dart';

class AppRouterConfiguration {
  final List<BaseAppRoute> topLevelRoutes;
  final GlobalKey<NavigatorState> globalNavigatorKey;
  final Map<String, String> _nameToPathMap = <String, String>{};
  final int redirectLimit;
  final AppRouterRedirect topRedirect;

  AppRouterConfiguration({
    required this.topLevelRoutes,
    required this.globalNavigatorKey,
    required this.topRedirect,
    required this.redirectLimit,
  }) {
    createNamedMap(parentFullPath: '', routes: topLevelRoutes);
  }

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
}
