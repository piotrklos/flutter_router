import 'package:flutter/material.dart';

import 'route.dart';

import 'route_finder.dart';

class AppRouterCubitProvider {
  final List<RouterPaths> _previousRoutes = [];

  RouterPaths _currentRouterPaths = RouterPaths.empty();

  @visibleForTesting
  List<RouterPaths> get previousRoutes => _previousRoutes;

  @visibleForTesting
  RouterPaths get currentRouterPaths => _currentRouterPaths;

  @visibleForTesting
  void setCurrentRouterPaths(RouterPaths routerPaths) {
    _currentRouterPaths = routerPaths;
  }

  @visibleForTesting
  void setPreviousRoutes(List<RouterPaths> routerPathsList) {
    _previousRoutes.clear();
    _previousRoutes.addAll(routerPathsList);
  }

  void restoreRouteInformation(RouterPaths routerPaths) {
    if (routerPaths == _currentRouterPaths) {
      return;
    }
    setNewRouterPaths(routerPaths);
  }

  void setNewRouterPaths(RouterPaths routerPaths) {
    if (routerPaths.isEmpty) {
      return;
    }

    if (_currentRouterPaths.isNotEmpty) {
      _previousRoutes.add(_currentRouterPaths);
    }
    _currentRouterPaths = routerPaths.copy();

    if (_previousRoutes.isNotEmpty) {
      removeUnusedProviders();
    }
    setNewProviders();
  }

  @visibleForTesting
  void setNewProviders() {
    for (var newRoute in _currentRouterPaths.allRoutes) {
      if (newRoute is AppPageRoute) {
        newRoute.onPush(_currentRouterPaths.cubitGetter);
      }
    }
  }

  @visibleForTesting
  void removeUnusedProviders() {
    final routesToRemove = getAllRouterPathsToRemove(
      newRouterPaths: _currentRouterPaths,
      previousRoutes: _previousRoutes,
    );
    final routerPathsToRemove = getAllRoutesToRemove(
      newRouterPaths: _currentRouterPaths,
      routerPathsToRemove: routesToRemove,
    );

    for (var route in routerPathsToRemove) {
      route.onPop();
    }

    _previousRoutes.removeWhere(
      (e) => routesToRemove.contains(e),
    );
  }

  @visibleForTesting
  List<BaseAppRoute> getAllRoutesToRemove({
    required List<RouterPaths> routerPathsToRemove,
    required RouterPaths newRouterPaths,
  }) {
    final currentRoutes = newRouterPaths.allRoutes;
    return routerPathsToRemove
        .expand((e) => e.allRoutes.reversed)
        .where((route) {
          return !currentRoutes.contains(route);
        })
        .toSet()
        .toList();
  }

  @visibleForTesting
  List<RouterPaths> getAllRouterPathsToRemove({
    required List<RouterPaths> previousRoutes,
    required RouterPaths newRouterPaths,
  }) {
    if (previousRoutes.isEmpty) {
      return [];
    }

    final lastRoute = previousRoutes.last;
    if (lastRoute.isEmpty) {
      return [];
    }

    final newLocation = newRouterPaths.location;
    if (newLocation == null) {
      return [];
    }

    final newFirstShellRoute =
        newRouterPaths.firstAppRouteOfType<ShellRouteBase>();
    AppPageRoute? shellRouteFirstsPage;
    if (newFirstShellRoute != null) {
      shellRouteFirstsPage = newRouterPaths.firstAppPageRouteForShell(
        newFirstShellRoute,
      );
    }

    final List<RouterPaths> toRemoveList = [];

    /// add old routes for the same base route
    toRemoveList.addAll(
      previousRoutes.where((routerPaths) {
        if (routerPaths.isEmpty) {
          return true;
        }
        final shellRoute = routerPaths.firstAppRouteOfType<ShellRouteBase>();
        if (newFirstShellRoute == shellRoute) {
          return shellRouteFirstsPage ==
              routerPaths.firstAppPageRouteForShell(shellRoute);
        }
        return true;
      }),
    );

    return toRemoveList;
  }

  /// return common AppPageRoute between new and old route
  @visibleForTesting
  List<BaseAppRoute> commonRoutes({
    required RouterPaths previousRoute,
    required RouterPaths newRouterPaths,
  }) {
    if (previousRoute.isEmpty) {
      return [];
    }
    return (previousRoute.allRoutes)
        .toSet()
        .intersection(
          newRouterPaths.allRoutes.toSet(),
        )
        .toList();
  }
}
