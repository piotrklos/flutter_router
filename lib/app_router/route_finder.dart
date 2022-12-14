import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../bloc/base_app_bloc.dart';
import 'configuration.dart';
import 'route.dart';
import 'router_exception.dart';
import 'typedef.dart';
import 'utils.dart';

class RouteFinder {
  final AppRouterConfiguration _configuration;

  RouteFinder(this._configuration);

  RouterPaths findForPath(
    String path, {
    Object? extra,
    required bool shouldBackToParent,
    RouterPaths? parentStack,
    Completer? completer,
  }) {
    final allRoutes = _findAllRouteForPath(
      path,
      extra: extra,
      completer: completer,
    );
    return RouterPaths(
      allRoutes,
      parentStack: parentStack,
      shouldBackToParent: shouldBackToParent,
    );
  }

  RouterPaths? proccessSkipToPaths({
    required RouterPaths routerPaths,
    required SkipOption skipOption,
    required int index,
  }) {
    if (routerPaths.length < index) {
      return null;
    }
    final foundRoute = routerPaths.routeForIndex(index);
    if (foundRoute == null) {
      return null;
    }
    if (routerPaths.length - 1 > index) {
      final newPaths = routerPaths._routes.whereNot(
        (e) => e == foundRoute,
      );
      if (newPaths.isEmpty) {
        return null;
      }
      return RouterPaths(
        newPaths.toList(),
      );
    }
    switch (skipOption) {
      case SkipOption.goToParent:
        final newRoutes = routerPaths._routes;
        newRoutes.removeAt(index);
        return RouterPaths(
          newRoutes,
        );
      case SkipOption.goToChild:
        final childRoute = foundRoute.route.routes.firstOrNull;
        if (childRoute == null || childRoute is! AppPageRoute) {
          return null;
        }
        final fullPath = PathUtils.joinPaths(
          routerPaths.location!,
          childRoute.path,
        );

        final childFoundRoute = FoundRoute.factory(
          route: childRoute,
          fullpath: fullPath,
          remainPathToCheck: childRoute.path,
          extra: null,
        );
        if (childFoundRoute == null) {
          return null;
        }
        final newRoutes = routerPaths._routes;
        newRoutes.removeAt(index);
        newRoutes.insert(index, childFoundRoute);
        return RouterPaths(
          newRoutes,
        );
    }
  }

  List<FoundRoute> _findAllRouteForPath(
    String path, {
    required Object? extra,
    required Completer? completer,
  }) {
    final routes = _getRouteRecursively(
      targetLocation: path,
      routes: _configuration.topLevelRoutes,
      parentFullPath: '',
      remainPathToCheck: path,
      extra: extra,
      completer: completer,
    );

    if (routes.isEmpty) {
      throw AppRouterException("No routes for path: $path");
    }
    return routes;
  }

  List<FoundRoute> _getRouteRecursively({
    required String targetLocation,
    required List<BaseAppRoute> routes,
    required String parentFullPath,
    required String remainPathToCheck,
    required Object? extra,
    required Completer? completer,
  }) {
    final List<List<FoundRoute>> result = [];

    for (final route in routes) {
      late final String fullPath;
      if (route is AppPageRoute) {
        fullPath = PathUtils.joinPaths(
          parentFullPath,
          route.path,
        );
      } else if (route is ShellRouteBase) {
        fullPath = parentFullPath;
      }

      final foundRoute = FoundRoute.factory(
        route: route,
        fullpath: fullPath,
        remainPathToCheck: remainPathToCheck,
        extra: extra,
      );

      /// This [foundRoute] is not in target location
      if (foundRoute == null) {
        continue;
      }

      if (foundRoute.route is AppPageRoute &&
          foundRoute.fullPath.toLowerCase() == targetLocation.toLowerCase()) {
        result.add([
          foundRoute.copyWith(
            completer: completer,
          )
        ]);
      } else if (route.routes.isEmpty) {
        continue;
      } else {
        final String newRemainPathToCheck;
        final String newParentFullPath;
        if (foundRoute.route is ShellRouteBase) {
          newRemainPathToCheck = remainPathToCheck;
          newParentFullPath = parentFullPath;
        } else {
          newRemainPathToCheck = targetLocation.substring(
            foundRoute.fullPath.length + (foundRoute.fullPath == '/' ? 0 : 1),
          );
          newParentFullPath = foundRoute.fullPath;
        }

        final subRouteMatch = _getRouteRecursively(
          targetLocation: targetLocation,
          routes: route.routes,
          parentFullPath: newParentFullPath,
          remainPathToCheck: newRemainPathToCheck,
          extra: extra,
          completer: completer,
        ).toList();

        if (subRouteMatch.isEmpty) {
          continue;
        }
        result.add([foundRoute, ...subRouteMatch]);
      }
      break;
    }
    if (result.isEmpty) {
      return [];
    }
    return result.first;
  }
}

class RouterPaths extends Equatable {
  final List<FoundRoute> _routes;
  final bool _shouldBackToParent;
  final RouterPaths? _parentStack;

  const RouterPaths(
    this._routes, {
    bool shouldBackToParent = false,
    RouterPaths? parentStack,
  })  : _parentStack = parentStack,
        _shouldBackToParent = shouldBackToParent;

  RouterPaths.empty()
      : _routes = [],
        _shouldBackToParent = false,
        _parentStack = null;

  bool get shouldBackToParent => _shouldBackToParent;

  RouterPaths? get parentRouterPaths => _parentStack;

  bool get isEmpty => _routes.isEmpty;

  bool get isNotEmpty => _routes.isNotEmpty;

  String? get location => _routes.lastOrNull?.fullPath;

  Object? get extra => _routes.lastOrNull?.extra;

  int get length => _routes.length;

  FoundRoute get last => _routes.last;

  FoundRoute? routeForIndex(int index) {
    if (length < index) {
      return null;
    }
    return _routes[index];
  }

  AppPageRoute? baseAppPageRoute() {
    return _routes
        .firstWhereOrNull(
          (e) => e.route is AppPageRoute,
        )
        ?.route as AppPageRoute?;
  }

  List<BaseAppRoute> get allRoutes {
    return _routes.map((e) => e.route).toList();
  }

  void addNew(FoundRoute foundRoute) {
    _routes.add(foundRoute);
  }

  FoundRoute popLast() {
    final removed = _routes.removeLast();

    while (_routes.isNotEmpty && _routes.last.route is ShellRouteBase) {
      _routes.removeLast();
    }
    return removed;
  }

  void replaceLast(FoundRoute foundRoute) {
    _routes.last = foundRoute;
  }

  List<FoundRoute> parentsRoutesFor(FoundRoute route) {
    final index = _routes.indexOf(route);
    if (index < 0) {
      return [];
    }
    return _routes.getRange(0, index).toList();
  }

  T? cubitGetter<T extends AppRouterBlocProvider>() {
    for (var foundRoute in _routes.toList().reversed) {
      final r = foundRoute.route;
      if (r is AppPageRoute) {
        final cubit = r.providers.firstWhereOrNull((e) => e is T);
        if (cubit != null) {
          return cubit as T;
        }
      }
    }
    return null;
  }

  bool get containsAnyCubitProviders {
    return _routes.any((e) {
      if (e.route is AppPageRoute) {
        return (e.route as AppPageRoute).providers.isNotEmpty;
      }
      return false;
    });
  }

  @override
  List<Object?> get props => [
        _routes,
      ];

  RouterPaths copy() {
    return RouterPaths(
      _routes.toList(),
      parentStack: _parentStack,
      shouldBackToParent: _shouldBackToParent,
    );
  }
}

class FoundRoute extends Equatable {
  final BaseAppRoute route;
  final String fullPath;
  final ValueKey<String>? pageKey;
  final Object? extra;
  final Exception? exception;
  final Completer<dynamic> completer;

  const FoundRoute._({
    required this.route,
    required this.fullPath,
    required this.extra,
    required this.completer,
    this.pageKey,
  }) : exception = null;

  FoundRoute.error({
    required this.fullPath,
    this.exception,
  })  : extra = null,
        pageKey = null,
        completer = Completer<void>(),
        route = AppPageRoute(
          path: fullPath,
          name: "error",
          builder: (_, __) => throw UnimplementedError(),
        );

  static FoundRoute? factory({
    required BaseAppRoute route,
    required String fullpath,
    required String remainPathToCheck,
    required Object? extra,
  }) {
    if (route is ShellRouteBase) {
      return FoundRoute._(
        route: route,
        fullPath: '',
        pageKey: ValueKey<String>(
          route.hashCode.toString(),
        ),
        extra: extra,
        completer: Completer<void>(),
      );
    } else if (route is AppPageRoute) {
      final isContained = route.isContained(remainPathToCheck);
      if (!isContained) {
        return null;
      }

      return FoundRoute._(
        route: route,
        fullPath: fullpath,
        extra: extra,
        completer: Completer<void>(),
      );
    }

    throw AppRouterException('Unexpected route type: $route');
  }

  @override
  String toString() => '_FoundRoute($fullPath)';

  FoundRoute copyWith({
    BaseAppRoute? route,
    String? fullPath,
    ValueKey<String>? pageKey,
    Object? extra,
    Completer<dynamic>? completer,
  }) {
    return FoundRoute._(
      route: route ?? this.route,
      fullPath: fullPath ?? this.fullPath,
      pageKey: pageKey ?? this.pageKey,
      extra: extra ?? this.extra,
      completer: completer ?? this.completer,
    );
  }

  @override
  List<Object?> get props => [
        route,
        pageKey,
        fullPath,
      ];
}
