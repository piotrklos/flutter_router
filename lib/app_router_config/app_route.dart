
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../app_router/route.dart';
import '../app_router/stacked_navigation_shell.dart';
import '../app_router/typedef.dart';
import '../bloc/base_app_bloc.dart';
import '../pages/home/tab_bar_page.dart';
import 'bloc_helper.dart';
import 'router_page_state.dart';

typedef CubitGetter = T? Function<T extends AppRouterBlocProvider>();

typedef RouteWidgetBuilder = Widget Function(
  BuildContext context,
  RouterPageState state,
);

abstract class IRoute {
  IRoute? _parent;
  BaseAppRoute mapToBaseAppRoute();

  final List<IRoute> _routes = [];

  void addRoute(IRoute route) {
    route._parent = this;
    _routes.add(route);
  }

  String get fullpath {
    if (_parent == null) {
      return "/$_route";
    }
    if (this is! PageRoute) {
      return "";
    }
    return "${_parent!.fullpath}/$_route";
  }

  String get _route {
    if (this is PageRoute) {
      return (this as PageRoute)._path;
    }
    return "";
  }
}

class TabRoute extends IRoute {
  final List<TabRouteItem> items;

  final Map<TabRouteItem, List<String>> _dependenciesMap = {};
  final Map<String, AppRouterBlocProvider> _dependenciesProvider = {};

  TabRoute({
    required this.items,
  }) {
    for (var tab in items) {
      for (var T in tab._providers) {
        _dependenciesMap.putIfAbsent(tab, () => []);
        _dependenciesMap[tab]!.add(T.toString());

        _dependenciesProvider.putIfAbsent(
          T.toString(),
          () => BlocHelper.getBlocByType(T),
        );
      }
    }
  }

  @override
  BaseAppRoute mapToBaseAppRoute() {
    return MultiShellRoute.stackedNavigationShell(
      routes: items
          .map(
            (e) => e.baseRoute.mapToBaseAppRoute(),
          )
          .toList(),
      stackItems: items
          .map(
            (e) => e._stackedNavigationItem(_dependenciesForTabRouteItem(e)),
          )
          .toList(),
      scaffoldBuilder: (context, currentIndex, itemsState, child) {
        return TabBarPage(
          currentIndex: currentIndex,
          itemsState: itemsState,
          body: child,
          tabRouteItems: items,
        );
      },
    );
  }

  List<AppRouterBlocProvider> _dependenciesForTabRouteItem(
    TabRouteItem item,
  ) {
    List<AppRouterBlocProvider> dependencies = [];
    final dependenciesNames = _dependenciesMap[item];
    dependenciesNames?.forEach((dependency) {
      final provider = _dependenciesProvider[dependency];
      if (provider != null) {
        dependencies.add(provider);
      }
    });

    return dependencies;
  }
}

class PageRoute extends IRoute {
  final String name;
  final String _path;
  final RouteWidgetBuilder builder;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final List<AppRouterBlocProvider> Function(
    CubitGetter cubitGetter,
  )? _providersBuilder;
  final AppRouterSkip? skip;

  PageRoute({
    required this.name,
    String? path,
    required this.builder,
     this.parentNavigatorKey,
    List<AppRouterBlocProvider> Function(
      CubitGetter cubitGetter,
    )?
        providersBuilder,
    this.skip,
  })  : _providersBuilder = providersBuilder,
        _path = path ?? name;

  @override
  BaseAppRoute mapToBaseAppRoute() {
    return AppPageRoute(
      builder: (context, state) {
        return builder(
          context,
          state.mapToRouterPageState(),
        );
      },
      name: name,
      path: _parent != null ? _path : "/$_path",
      routes: _routes
          .map(
            (e) => e.mapToBaseAppRoute(),
          )
          .toList(),
      providersBuilder: _providersBuilder,
      skip: skip,
      parentNavigatorKey: parentNavigatorKey,
    );
  }
}

class TabRouteItem extends Equatable {
  final IRoute baseRoute;
  final String name;
  final IconData iconData;
  final GlobalKey<NavigatorState> navigatorKey;
  final List<Object> _providers;

  const TabRouteItem({
    required this.baseRoute,
    required this.name,
    required this.iconData,
    required this.navigatorKey,
    List<Object> providers = const [],
  }) : _providers = providers;

  StackedNavigationItem _stackedNavigationItem(
    List<AppRouterBlocProvider> providers,
  ) {
    return StackedNavigationItem(
      rootRoutePath: baseRoute.fullpath,
      navigatorKey: navigatorKey,
      providers: providers
          .map(
            (e) => e.blocProvider,
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        baseRoute,
        name,
        iconData,
        navigatorKey,
        _providers,
      ];
}
