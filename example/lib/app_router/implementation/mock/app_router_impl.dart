import 'package:app_router/app_router.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../pages/shared/error_page.dart';
import '../../interface/location.dart';
import '../../interface/route.dart';
import '../../routes/shared_routes.dart';
import '../../routes/tabs/tab_config.dart';
import '../app_router_impl.dart';
import '../route_extensions.dart';
import '../mapper.dart';

class AppRotuerMockImplementation extends AppRotuerImplementation {
  static final _globalNavigationKey = GlobalKey<NavigatorState>();
  final List<IRoute> routes;

  late final AppRouter _appRouter;

  AppRotuerMockImplementation({
    required this.routes,
  });

  @override
  Future<void> init({
    String? initialLocationName,
    List<NavigatorObserver> observers = const [],
  }) {
    final List<IRoute> correctRoutes = [];
    if (routes.isEmpty) {
      final sharedRoutes = SharedRoutes(_globalNavigationKey);
      final tabConfig = TabConfig();

      correctRoutes.addAll([
        ...sharedRoutes.routes,
        tabConfig.tabRoute,
      ]);
    } else {
      correctRoutes.addAll(routes);
    }

    _appRouter = AppRouter(
      navigatorKey: _globalNavigationKey,
      routes: correctRoutes
          .map(
            (e) => e.mapToBaseAppRoute(withProviderBuilder: false),
          )
          .toList(),
      errorBuilder: (ctx, state) {
        return ErrorPage(
          message: state.exception.toString(),
        );
      },
      initialLocationName: initialLocationName,
      observers: observers,
    );
    return SynchronousFuture(null);
  }

  @override
  BackButtonDispatcher? get backButtonDispatcher =>
      _appRouter.backButtonDispatcher;

  @override
  RouteInformationParser<RouterPaths> get routeInformationParser =>
      _appRouter.routeInformationParser;

  @override
  RouteInformationProvider? get routeInformationProvider =>
      _appRouter.routeInformationProvider;

  @override
  RouterDelegate<RouterPaths> get routerDelegate => _appRouter.routerDelegate;

  @override
  Future<T?> goNamed<T extends Object?>(
    String name, {
    Object? extra,
    bool backToParent = false,
  }) {
    return _appRouter.goNamed<T>(
      name,
      backToParent: backToParent,
      extra: extra,
    );
  }

  @override
  void pop<T extends Object?>([T? result]) {
    return _appRouter.pop<T>(result);
  }

  @override
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  }) {
    return _appRouter.pushNamed(
      name,
      extra: extra,
    );
  }

  @override
  PBRouteLocation? get currentLocation =>
      _appRouter.currentLocation?.mapToPBRouteLocation();
}
