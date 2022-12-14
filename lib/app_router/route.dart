import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../bloc/base_app_bloc.dart';
import 'router_exception.dart';
import 'stacked_navigation_shell.dart';
import 'typedef.dart';

abstract class BaseAppRoute extends Equatable {
  const BaseAppRoute._({
    this.routes = const <BaseAppRoute>[],
  });

  final List<BaseAppRoute> routes;

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
}

/// Base Page route
class AppPageRoute extends BaseAppRoute {
  final String path;
  final String name;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final AppRouterWidgetBuilder builder;
  final AppRouterRedirect? redirect;
  final AppRouterSkip? skip;

  final List<AppRouterBlocProvider> Function(
    AppRouteProvidersBuilder cubitGetter,
  )? _providersBuilder;
  final List<AppRouterBlocProvider> _tempProvidersList = [];

  List<AppRouterBlocProvider> get providers {
    return _tempProvidersList;
  }

  AppPageRoute({
    required this.path,
    required this.name,
    required this.builder,
    this.redirect,
    this.skip,
    List<BaseAppRoute> routes = const <BaseAppRoute>[],
    this.parentNavigatorKey,
    List<AppRouterBlocProvider> Function(
      AppRouteProvidersBuilder cubitGetter,
    )?
        providersBuilder,
  })  : assert(path.isNotEmpty, "Path cannot be empty"),
        assert(name.isNotEmpty, "Name cannot be empty"),
        _providersBuilder = providersBuilder,
        super._(routes: routes);

  void onPush(AppRouteProvidersBuilder cubitGetter) {
    if (_tempProvidersList.isNotEmpty) {
      return;
    }
    _tempProvidersList.addAll(_providersBuilder?.call(cubitGetter) ?? []);
  }

  void onPop() {
    _tempProvidersList.clear();
  }

  /// For example:
  /// /test2/details contained /test2 -> true
  /// /test2/details contained /test -> false
  /// Go_router use RegExp for that
  bool isContained(String route) {
    if (path == route) {
      return true;
    }
    final isStart = route.startsWith(path);
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

  const ShellRouteBase._({
    required this.builder,
    required List<BaseAppRoute> routes,
  }) : super._(routes: routes);

  GlobalKey<NavigatorState> navigatorKeyForChildRoute(BaseAppRoute route);
}

class ShellRoute extends ShellRouteBase {
  ShellRoute({
    required ShellRouteBuilder builder,
    required List<BaseAppRoute> routes,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : assert(routes.isNotEmpty, "Routes cannot be empty"),
        navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        super._(routes: routes, builder: builder) {
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

class MultiShellRoute extends ShellRouteBase {
  final List<GlobalKey<NavigatorState>> navigatorKeys;

  MultiShellRoute._({
    required this.navigatorKeys,
    required ShellRouteBuilder builder,
    required List<BaseAppRoute> routes,
  })  : assert(routes.isNotEmpty, "Routes cannot be empty"),
        assert(
          navigatorKeys.length == routes.length,
          "Navigator keys length must be exactly the same as routes length",
        ),
        super._(routes: routes, builder: builder) {
    for (int i = 0; i < routes.length; ++i) {
      final BaseAppRoute route = routes[i];
      if (route is AppPageRoute) {
        assert(
          route.parentNavigatorKey == null ||
              route.parentNavigatorKey == navigatorKeys[i],
          "Parent route navigator key cannot be diffrent than Shell Route navigator key",
        );
      }
    }
  }

  factory MultiShellRoute.stackedNavigationShell({
    required List<BaseAppRoute> routes,
    required List<StackedNavigationItem> stackItems,
    StackedNavigationScaffoldBuilder? scaffoldBuilder,
  }) {
    return MultiShellRoute._(
      routes: routes,
      navigatorKeys: stackItems.map((e) => e.navigatorKey).toList(),
      builder: (context, state, child) {
        assert(child is Navigator);
        return StackedNavigationShell(
          currentNavigator: child as Navigator,
          currentRouterState: state,
          stackItems: stackItems,
          scaffoldBuilder: scaffoldBuilder,
        );
      },
    );
  }

  @override
  GlobalKey<NavigatorState> navigatorKeyForChildRoute(BaseAppRoute route) {
    final baseRoute = routes.firstWhere((e) => e.isChild(route));

    final int routeIndex = routes.indexOf(baseRoute);
    if (routeIndex < 0) {
      throw AppRouterException(
        'Route $route is not a child of this MultiShellRoute $this',
      );
    }
    return navigatorKeys[routeIndex];
  }

  @override
  List<Object?> get props => [
        ...super.props,
        navigatorKeys,
      ];
}
