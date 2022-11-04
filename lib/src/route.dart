import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../app_router.dart';
import 'inherited_statefull_navigation_shell.dart';
import 'router_exception.dart';

abstract class BaseAppRoute extends Equatable {
  final List<BaseAppRoute> routes;
  final String name;

  const BaseAppRoute._({
    this.routes = const <BaseAppRoute>[],
    required this.name,
  });

  @override
  List<Object?> get props => [routes];

  bool isChild(BaseAppRoute route) {
    if (this == route) {
      return true;
    }
    if (routes.isEmpty) {
      return false;
    }
    return routes.any((e) {
      return e.isChild(route);
    });
  }

  void onPop();
}

/// Base Page route
class AppPageRoute extends BaseAppRoute {
  final String path;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final AppRouterWidgetBuilder builder;
  final AppRouterSkip? skip;

  final List<AppRouterBlocProvider> Function(
    AppRouteProvidersBuilder cubitGetter,
  )? _providersBuilder;
  final List<AppRouterBlocProvider> _tempProvidersList = [];
  final VoidCallback? _onPop;
  final VoidCallback? _onPush;

  List<AppRouterBlocProvider> get providers {
    return _tempProvidersList;
  }

  AppPageRoute({
    required this.path,
    required String name,
    required this.builder,
    this.skip,
    List<BaseAppRoute> routes = const <BaseAppRoute>[],
    this.parentNavigatorKey,
    List<AppRouterBlocProvider> Function(
      AppRouteProvidersBuilder cubitGetter,
    )?
        providersBuilder,
    VoidCallback? onPop,
    VoidCallback? onPush,
  })  : assert(path.isNotEmpty, "Path cannot be empty"),
        assert(name.isNotEmpty, "Name cannot be empty"),
        _providersBuilder = providersBuilder,
        _onPop = onPop,
        _onPush = onPush,
        super._(
          routes: routes,
          name: name,
        );

  @visibleForTesting
  void addTempProvidersList(List<AppRouterBlocProvider> providers) {
    _tempProvidersList.addAll(providers);
  }

  @visibleForTesting
  void clearProviders() {
    _tempProvidersList.clear();
  }

  void onPush(AppRouteProvidersBuilder cubitGetter) {
    _onPush?.call();
    if (_tempProvidersList.isNotEmpty) {
      return;
    }
    _tempProvidersList.addAll(_providersBuilder?.call(cubitGetter) ?? []);
  }

  @override
  void onPop() {
    for (var provider in _tempProvidersList) {
      provider.close();
    }
    _tempProvidersList.clear();
    _onPop?.call();
  }

  /// For example:
  /// /test2/details contained /test2 -> true
  /// /test2/details contained /test -> false
  /// Go_router use RegExp for that
  bool isContained(String route) {
    if (path.toLowerCase() == route.toLowerCase()) {
      return true;
    }
    final isStart = route.toLowerCase().startsWith(path.toLowerCase());
    if (!isStart) {
      return false;
    }
    if (path == "/") {
      return true;
    }
    return route.substring(path.length).startsWith('/');
  }

  @override
  List<Object?> get props => [
        ...super.props,
        path,
        name,
        parentNavigatorKey,
      ];
}

/// Route to displays a UI shell around the matching child route.
abstract class ShellRouteBase extends BaseAppRoute {
  final ShellRouteBuilder builder;
  final VoidCallback? _onPop;

  const ShellRouteBase._({
    required this.builder,
    required List<BaseAppRoute> routes,
    VoidCallback? onPop,
  })  : _onPop = onPop,
        super._(
          routes: routes,
          name: "",
        );

  GlobalKey<NavigatorState> navigatorKeyForChildRoute(BaseAppRoute route);

  @override
  void onPop() {
    _onPop?.call();
  }
}

class ShellRoute extends ShellRouteBase {
  ShellRoute({
    required ShellRouteBuilder builder,
    required List<BaseAppRoute> routes,
    GlobalKey<NavigatorState>? navigatorKey,
    this.restorationScopeId,
    VoidCallback? onPop,
  })  : assert(routes.isNotEmpty, "Routes cannot be empty"),
        navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        super._(
          routes: routes,
          builder: builder,
          onPop: onPop,
        ) {
    for (final BaseAppRoute route in routes) {
      if (route is AppPageRoute) {
        assert(
          route.parentNavigatorKey == null ||
              route.parentNavigatorKey == navigatorKey,
          "Parent route navigator key cannot be diffrent than Shell Route navigator key",
        );
      }
    }
  }

  final GlobalKey<NavigatorState> navigatorKey;
  final String? restorationScopeId;

  @override
  GlobalKey<NavigatorState> navigatorKeyForChildRoute(BaseAppRoute route) {
    return navigatorKey;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        navigatorKey,
      ];
}

class StatefulShellRoute extends ShellRouteBase {
  final List<ShellRouteBranch> branches;
  final bool preloadBranches;

  StatefulShellRoute({
    required List<ShellRouteBranch> branches,
    required ShellRouteBuilder builder,
    bool preloadBranches = false,
    VoidCallback? onPop,
  }) : this._(
          routes: _rootRoutes(branches),
          branches: branches,
          builder: builder,
          preloadBranches: preloadBranches,
          onPop: onPop,
        );

  StatefulShellRoute.rootRoutes({
    required List<AppPageRoute> routes,
    required ShellRouteBuilder builder,
    bool preloadBranches = false,
    VoidCallback? onPop,
  }) : this._(
          routes: routes,
          branches: routes.map((e) {
            return ShellRouteBranch(
              rootRoute: e,
              navigatorKey: e.parentNavigatorKey,
            );
          }).toList(),
          builder: builder,
          preloadBranches: preloadBranches,
          onPop: onPop,
        );

  StatefulShellRoute._({
    required List<BaseAppRoute> routes,
    required this.branches,
    required ShellRouteBuilder builder,
    required this.preloadBranches,
    required VoidCallback? onPop,
  })  : assert(branches.isNotEmpty),
        assert(
          _debugUniqueNavigatorKeys(branches).length == branches.length,
          'Navigator keys must be unique',
        ),
        super._(
          builder: builder,
          routes: routes,
          onPop: onPop,
        ) {
    for (int i = 0; i < routes.length; ++i) {
      final route = routes[i];
      if (route is AppPageRoute) {
        assert(
          route.parentNavigatorKey == null ||
              route.parentNavigatorKey == branches[i].navigatorKey,
        );
      }
    }
  }

  @override
  GlobalKey<NavigatorState> navigatorKeyForChildRoute(BaseAppRoute route) {
    final baseRoute = routes.firstWhereOrNull((e) => e.isChild(route));
    if (baseRoute == null) {
      throw AppRouterException(
        'Route $route is not a child of this MultiShellRoute $this',
      );
    }
    final int routeIndex = routes.indexOf(baseRoute);
    return branches[routeIndex].navigatorKey;
  }

  static StatefulShellRouteState of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<InheritedStatefulNavigationShell>();
    assert(
      inherited != null,
      'No InheritedStatefulNavigationShell found in context',
    );
    return inherited!.routeState;
  }

  static Set<GlobalKey<NavigatorState>> _debugUniqueNavigatorKeys(
    List<ShellRouteBranch> branches,
  ) {
    return Set<GlobalKey<NavigatorState>>.from(
      branches.map(
        (ShellRouteBranch e) => e.navigatorKey,
      ),
    );
  }

  static List<BaseAppRoute> _rootRoutes(
    List<ShellRouteBranch> branches,
  ) {
    return branches.map((e) => e.rootRoute).toList();
  }

  @override
  List<Object?> get props => [
        ...super.props,
        branches,
      ];
}

class ShellRouteBranch {
  ShellRouteBranch({
    required this.rootRoute,
    GlobalKey<NavigatorState>? navigatorKey,
    this.defaultLocation,
    this.restorationScopeId,
    this.providersBuilder,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        assert(
          rootRoute is AppPageRoute || defaultLocation != null,
          'Provide a defaultLocation or use a AppPageRoute as rootRoute',
        );

  final GlobalKey<NavigatorState> navigatorKey;

  final BaseAppRoute rootRoute;
  final AppRouterLocation? defaultLocation;
  final String? restorationScopeId;
  final ValueGetter<List<AppRouterBlocProvider>>? providersBuilder;
}
