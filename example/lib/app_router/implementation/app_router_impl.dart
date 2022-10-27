import 'package:app_router/app_router.dart';
import 'package:app_router/route_finder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../pages/shared/error_page.dart';
import '../interface/router.dart';
import '../routes/shared_routes.dart';
import '../routes/tabs/tab_config.dart';
import 'route_extensions.dart';

@Injectable(as: PBAppRouter)
class AppRotuerImplementation implements PBAppRouter<RouterPaths> {
  static final _globalNavigationKey = GlobalKey<NavigatorState>();

  late final AppRouter _appRouter;

  @override
  Future<void> init() {
    final sharedRoutes = SharedRoutes(_globalNavigationKey);
    final tabConfig = TabConfig();
    _appRouter = AppRouter(
      navigatorKey: _globalNavigationKey,
      routes: [
        ...sharedRoutes.routes,
        tabConfig.tabRoute,
      ]
          .map(
            (e) => e.mapToBaseAppRoute(),
          )
          .toList(),
      errorBuilder: (ctx, state) {
        return ErrorPage(
          message: state.exception.toString(),
        );
      },
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
  Future<T?> go<T extends Object?>(
    String location, {
    Object? extra,
    bool backToParent = false,
  }) {
    return _appRouter.go<T>(
      location,
      backToParent: backToParent,
      extra: extra,
    );
  }

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
  Future<T?> push<T extends Object?>(
    String location, {
    Object? extra,
  }) {
    return _appRouter.push<T>(
      location,
      extra: extra,
    );
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
  String? get currentLocation => _appRouter.currentLocation;
}
