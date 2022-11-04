import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'bloc_provider.dart';
import 'router_exception.dart';
import 'stacked_navigation_shell.dart';
import 'typedef.dart';

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
  final List<StackedNavigationItem> _stackItems;

  MultiShellRoute._({
    required this.navigatorKeys,
    required List<StackedNavigationItem> stackItems,
    required ShellRouteBuilder builder,
    required List<BaseAppRoute> routes,
    required VoidCallback? onPop,
  })  : assert(routes.isNotEmpty, "Routes cannot be empty"),
        assert(
          navigatorKeys.length == routes.length,
          "Navigator keys length must be exactly the same as routes length",
        ),
        _stackItems = stackItems,
        super._(
          routes: routes,
          builder: builder,
          onPop: onPop,
        ) {
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
    VoidCallback? onPop,
  }) {
    return MultiShellRoute._(
      routes: routes,
      stackItems: stackItems,
      navigatorKeys: stackItems.map((e) => e.navigatorKey).toList(),
      onPop: onPop,
      builder: (context, state, child) {
        assert(child is Navigator);
        return StackedNavigationShell(
          currentNavigator: child as Navigator,
          stackItems: stackItems,
          scaffoldBuilder: scaffoldBuilder,
        );
      },
    );
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
    return navigatorKeys[routeIndex];
  }

  @override
  void onPop() {
    for (final item in _stackItems) {
      item.providers?.forEach((bloc) {
        bloc.close();
      });
    }
    super.onPop();
  }

  @override
  List<Object?> get props => [
        ...super.props,
        navigatorKeys,
      ];
}
