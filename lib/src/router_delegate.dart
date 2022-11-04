import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'builder.dart';
import 'configuration.dart';
import 'route.dart';
import 'route_finder.dart';
import 'router_exception.dart';
import 'typedef.dart';

class AppRouterDelegate extends RouterDelegate<RouterPaths>
    with PopNavigatorRouterDelegateMixin<RouterPaths>, ChangeNotifier {
  final AppRouterConfiguration _configuration;
  final AppRouterBuilder _appRouterBuilder;

  RouterPaths _routerPaths = RouterPaths.empty();
  @visibleForTesting
  RouterPaths get routerPaths => _routerPaths;
  final Map<String, int> _pushCounts = {};

  AppRouterDelegate({
    required AppRouterConfiguration configuration,
    required AppRouterBuilderWithNavigator builderWithNavigator,
    required AppRouterWidgetBuilder errorBuilder,
    required List<NavigatorObserver> observers,
    required RouteFinder routerFinder,
    String? restorationScopeId,
  })  : _configuration = configuration,
        _appRouterBuilder = AppRouterBuilder(
          builderWithNavigator: builderWithNavigator,
          configuration: configuration,
          errorBuilder: errorBuilder,
          observers: observers,
          restorationScopeId: restorationScopeId,
          routeFinder: routerFinder,
        );

  @override
  Widget build(BuildContext context) {
    return _appRouterBuilder.build(
      context: context,
      routerPaths: _routerPaths,
      onPop: pop,
    );
  }

  @override
  Future<bool> popRoute() async {
    final int routesCount = _routerPaths.length;
    BaseAppRoute? childRoute;

    for (int i = routesCount - 1; i >= 0; i -= 1) {
      final foundRoute = _routerPaths.routeForIndex(i);
      if (foundRoute == null) {
        continue;
      }

      final route = foundRoute.route;

      if (route is AppPageRoute && route.parentNavigatorKey != null) {
        final navigatorState = route.parentNavigatorKey!.currentState;

        if ((await navigatorState?.maybePop()) ?? false) {
          return true;
        }
      } else if (route is ShellRouteBase && childRoute != null) {
        final navigatorKey = route.navigatorKeyForChildRoute(childRoute);

        final bool didPop = await navigatorKey.currentState!.maybePop();

        if (didPop) {
          return didPop;
        }
      }
      childRoute = route;
    }

    final NavigatorState? navigator = navigatorKey.currentState;

    if (navigator == null) {
      return SynchronousFuture<bool>(false);
    }

    return navigator.maybePop();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      _configuration.globalNavigatorKey;

  @override
  RouterPaths? get currentConfiguration => _routerPaths;

  @override
  Future<void> setNewRoutePath(RouterPaths configuration) {
    _routerPaths = configuration;
    assert(_routerPaths.isNotEmpty);
    return SynchronousFuture(null);
  }

  bool canPop() {
    final int routesCount = _routerPaths.length;
    BaseAppRoute? childRoute;

    for (int i = routesCount - 1; i >= 0; i -= 1) {
      final foundRoute = _routerPaths.routeForIndex(i);
      if (foundRoute == null) {
        continue;
      }
      final route = foundRoute.route;
      if (route is AppPageRoute && route.parentNavigatorKey != null) {
        final navigatorState = route.parentNavigatorKey!.currentState;
        if (navigatorState?.canPop() ?? false) {
          return true;
        }
      } else if (route is ShellRouteBase && childRoute != null) {
        final navigatorKey = route.navigatorKeyForChildRoute(childRoute);
        final navigatorState = navigatorKey.currentState;

        if (navigatorState?.canPop() ?? false) {
          return true;
        }
      }
      childRoute = route;
    }
    return navigatorKey.currentState?.canPop() ?? false;
  }

  void pop<T extends Object?>([T? result]) {
    if (_routerPaths.shouldBackToCaller &&
        _routerPaths.parentRouterPaths != null) {
      if (!_routerPaths.last.completer.isCompleted) {
        _routerPaths.last.completer.complete(result);
      }
      setNewRoutePath(_routerPaths.parentRouterPaths!);
    } else {
      final removed = _routerPaths.popLast();
      removed.completer.complete(result);
    }
    notifyListeners();
  }

  void push<T extends Object?>(
    FoundRoute foundRoute,
    Completer<T> completer,
  ) {
    if (foundRoute.route is ShellRouteBase) {
      throw AppRouterException('ShellRoutes cannot be pushed');
    }
    final fullPath = foundRoute.fullPath;
    final count = (_pushCounts[fullPath] ?? 0) + 1;
    _pushCounts[fullPath] = count;
    final newPageKey = ValueKey('$fullPath-count:$count');
    _routerPaths.addNew(
      foundRoute.copyWith(
        pageKey: newPageKey,
        completer: completer,
      ),
    );
    notifyListeners();
  }

  void replace(FoundRoute foundRoute) {
    assert(_routerPaths.isNotEmpty);
    _routerPaths.replaceLast(foundRoute);
    notifyListeners();
  }

  void replaceRouterPaths(RouterPaths routerPaths) {
    _routerPaths = routerPaths.copy(shouldBackToCaller: false);
    notifyListeners();
  }
}
