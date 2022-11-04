import 'package:flutter/material.dart';
import 'dart:async';

import 'cubit_provider.dart';
import 'location.dart';
import 'configuration.dart';
import 'information_parser.dart';
import 'information_provider.dart';
import 'inherited_router.dart';
import 'route.dart';
import 'route_finder.dart';
import 'router_delegate.dart';
import 'router_information_state_object.dart';
import 'router_skipper.dart';
import 'typedef.dart';

class AppRouter extends ChangeNotifier with NavigatorObserver {
  late final AppRouteInformationParser _routeInformationParser;
  late final AppRouteInformationProvider _routeInformationProvider;
  late final AppRouterDelegate _routerDelegate;
  late final AppRouterConfiguration _configuration;
  late final AppRouterCubitProvider _cubitProvider;

  AppRouter({
    required List<BaseAppRoute> routes,
    required AppRouterWidgetBuilder errorBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
    String? initialLocation,
    String? initialLocationName,
    Listenable? refreshListenable,
  }) {
    _configuration = AppRouterConfiguration(
      globalNavigatorKey: navigatorKey ?? GlobalKey<NavigatorState>(),
      topLevelRoutes: routes,
    );

    _cubitProvider = AppRouterCubitProvider();
    final routerFinder = RouteFinder(_configuration);

    _routeInformationParser = AppRouteInformationParser(
      routerFinder,
      _cubitProvider,
      AppRouterSkipper(_configuration),
    );

    String? _location;
    if (initialLocationName != null) {
      _location = _configuration.getFullPathForName(initialLocationName);
    } else {
      _location = initialLocation;
    }

    _routeInformationProvider = AppRouteInformationProvider(
      initialRouteInformation: RouteInformation(
        location: _location ?? "/",
      ),
      refreshListenable: refreshListenable,
    );

    _routerDelegate = AppRouterDelegate(
      configuration: _configuration,
      errorBuilder: errorBuilder,
      observers: [...observers ?? [], this],
      restorationScopeId: restorationScopeId,
      routerFinder: routerFinder,
      builderWithNavigator: (context, _, nav) {
        return InheritedAppRouter(
          appRouter: this,
          child: nav,
        );
      },
    );
  }

  BackButtonDispatcher? get backButtonDispatcher => RootBackButtonDispatcher();

  AppRouteInformationParser get routeInformationParser =>
      _routeInformationParser;

  AppRouteInformationProvider? get routeInformationProvider =>
      _routeInformationProvider;

  AppRouterDelegate get routerDelegate => _routerDelegate;

  AppRouterLocation? get currentLocation =>
      _routerDelegate.currentConfiguration?.location;

  String _fullPathForName(String name) => _configuration.getFullPathForName(
        name,
      );

  /// completer work only when [backToCaller] is true
  Future<T?> go<T extends Object?>(
    String location, {
    Object? extra,
    bool backToCaller = false,
  }) async {
    final Completer<T> completer = Completer<T>();
    _routeInformationProvider.value = RouteInformation(
      location: location,
      state: RouterInformationStateObject<T>(
        extra: extra,
        backToCaller: backToCaller,
        parentStack: _routerDelegate.currentConfiguration,
        completer: completer,
      ),
    );
    return completer.future;
  }

  /// completer work only when [backToCaller] is true
  Future<T?> goNamed<T extends Object?>(
    String name, {
    Object? extra,
    bool backToCaller = false,
  }) {
    return go(
      _fullPathForName(name),
      extra: extra,
      backToCaller: backToCaller,
    );
  }

  Future<T?> push<T extends Object?>(
    String location, {
    Object? extra,
  }) async {
    final Completer<T> completer = Completer<T>();
    _routeInformationParser
        .parseRouteInformation(
      RouteInformation(location: location, state: extra),
    )
        .then((value) {
      _routerDelegate.push(value.last, completer);
    });

    return completer.future;
  }

  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  }) {
    return push(_fullPathForName(name), extra: extra);
  }

  bool canPop() => _routerDelegate.canPop();

  void pop<T extends Object?>([T? result]) {
    _routerDelegate.pop<T>(result);
  }

  void refresh() {
    _routeInformationProvider.notifyListeners();
  }

  static AppRouter of(BuildContext context) {
    final InheritedAppRouter? inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedAppRouter>();
    return inherited!.appRouter;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    notifyListeners();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    notifyListeners();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    notifyListeners();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    notifyListeners();
  }

  @override
  void dispose() {
    _routeInformationProvider.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}