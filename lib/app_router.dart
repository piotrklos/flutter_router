library app_router;

export 'typedef.dart';
export 'app_router_bloc_provider.dart';
export 'app_router_cubit_provider.dart';
export 'app_router_page_state.dart';
export 'route.dart';
export 'stacked_navigation_shell.dart';
export 'app_router_bloc_provider.dart';
export 'app_router_location.dart';

import 'package:flutter/material.dart';
import 'dart:async';

import 'app_router_cubit_provider.dart';
import 'app_router_location.dart';
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
    Listenable? refreshListenable,
  }) {
    _configuration = AppRouterConfiguration(
      globalNavigatorKey: navigatorKey ?? GlobalKey<NavigatorState>(),
      topLevelRoutes: routes,
    );

    _cubitProvider = AppRouterCubitProvider(
        // _configuration,
        );

    _routeInformationParser = AppRouteInformationParser(
      RouteFinder(_configuration),
      _cubitProvider,
      AppRouterSkipper(_configuration),
    );

    _routeInformationProvider = AppRouteInformationProvider(
      initialRouteInformation: RouteInformation(
        location: initialLocation ?? "/",
      ),
      refreshListenable: refreshListenable,
    );

    _routerDelegate = AppRouterDelegate(
      configuration: _configuration,
      errorBuilder: errorBuilder,
      observers: [...observers ?? [], this],
      restorationScopeId: restorationScopeId,
      builderWithNavigator: (context, _, nav) => InheritedAppRouter(
        appRouter: this,
        child: nav,
      ),
    );
  }

  BackButtonDispatcher? get backButtonDispatcher => RootBackButtonDispatcher();

  RouteInformationParser<RouterPaths> get routeInformationParser =>
      _routeInformationParser;

  RouteInformationProvider? get routeInformationProvider =>
      _routeInformationProvider;

  RouterDelegate<RouterPaths> get routerDelegate => _routerDelegate;

  AppRouterLocation? get currentLocation =>
      _routerDelegate.currentConfiguration?.location;

  String _fullPathForName(String name) => _configuration.getFullPathForName(
        name,
      );

  /// completer work only when [backToParent] is true
  Future<T?> go<T extends Object?>(
    String location, {
    Object? extra,
    bool backToParent = false,
  }) async {
    final Completer<T> completer = Completer<T>();
    _routeInformationProvider.value = RouteInformation(
      location: location,
      state: RouterInformationStateObject<T>(
        extra: extra,
        backToParent: backToParent,
        parentStack: _routerDelegate.currentConfiguration,
        completer: completer,
      ),
    );
    return completer.future;
  }

  /// completer work only when [backToParent] is true
  Future<T?> goNamed<T extends Object?>(
    String name, {
    Object? extra,
    bool backToParent = false,
  }) {
    return go(
      _fullPathForName(name),
      extra: extra,
      backToParent: backToParent,
    );
  }

  Future<T?> push<T extends Object?>(
    String location, {
    Object? extra,
  }) async {
    final Completer<T> completer = Completer<T>();
    final routerPaths = await _routeInformationParser.parseRouteInformation(
      RouteInformation(location: location, state: extra),
    );
    _routerDelegate.push(routerPaths.last, completer);
    return completer.future;
  }

  Future<T?> pushNamed<T extends Object?>(String name, {Object? extra}) {
    return push(_fullPathForName(name), extra: extra);
  }

  void replace(String location, {Object? extra}) {
    _routeInformationParser
        .parseRouteInformation(
      RouteInformation(
        location: location,
        state: extra,
      ),
    )
        .then((routerPaths) {
      _routerDelegate.replace(routerPaths.last);
    });
  }

  void replaceNamed(String name, {Object? extra}) {
    replace(
      _fullPathForName(name),
      extra: extra,
    );
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
