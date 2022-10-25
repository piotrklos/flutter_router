import 'route.dart';

import '../bloc/base_app_bloc.dart';
import 'configuration.dart';
import 'route_finder.dart';

class AppRouterCubitProvider {
  final AppRouterConfiguration routerConfig;
  final List<AppRouterBlocProvider> currentProviders = [];

  AppRouterCubitProvider(this.routerConfig);

  RouterPaths _currentRouterPaths = RouterPaths.empty();
  final List<RouterPaths> _previousRoutes = [];

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
    _setNewProviders();
  }

  void _setNewProviders() {
    final commonRoutes = _commonRoutes();

    /// new added routes
    final newRoutes =
        _currentRouterPaths.allRoutes.whereType<AppPageRoute>().toList()
          ..removeWhere(
            (e) => commonRoutes.contains(e),
          );

    /// remove unused cubit providers
    _removeUnusedProviders();

    for (var route in newRoutes) {
      route.onPush(_currentRouterPaths.cubitGetter);
    }
  }

  void _removeUnusedProviders() {
    if (_previousRoutes.isEmpty) {
      return;
    }
    final lastRoute = _previousRoutes.last;
    if (lastRoute.isEmpty) {
      return;
    }
    final newLocation = _currentRouterPaths.location;
    if (newLocation == null) {
      return;
    }

    /// first app page route for this paths
    final baseAppRoute = _currentRouterPaths.baseAppPageRoute();
    if (baseAppRoute == null) {
      return;
    }

    /// if the same screen
    if (baseAppRoute == lastRoute.last.route) {
      _previousRoutes.removeLast();
      return;
    }

    List<RouterPaths> toRemove = [];

    for (var route in _previousRoutes) {
      if (route.location == null) {
        continue;
      }
      if (route.location!.startsWith(baseAppRoute.path)) {
        toRemove.add(route);
      } else if (!route.containsAnyCubitProviders) {
        toRemove.add(route);
      }
    }

    if (toRemove.isEmpty) {
      return;
    }

    final oldPageRoutes = toRemove
        .map((e) => e.allRoutes)
        .expand((e) => e)
        .whereType<AppPageRoute>();

    final allCurrentRoutes = _currentRouterPaths.allRoutes;
    final oldPageToPop = oldPageRoutes
        .where(
          (route) => !allCurrentRoutes.contains(route),
        )
        .toList();
    for (var route in oldPageToPop) {
      route.onPop();
    }

    _previousRoutes.removeWhere((e) => toRemove.contains(e));
  }

  /// return common AppPageRoute between new and old route
  List<AppPageRoute> _commonRoutes() {
    if (_previousRoutes.isEmpty) {
      return [];
    }
    return (_previousRoutes.last.allRoutes)
        .toSet()
        .intersection(
          _currentRouterPaths.allRoutes.toSet(),
        )
        .toList()
        .whereType<AppPageRoute>()
        .toList();
  }
}
