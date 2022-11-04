import 'package:app_router/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../pages/shared/error_page.dart';
import '../interface/location.dart';
import '../interface/router.dart';
import '../routes/shared_routes.dart';
import '../routes/tabs/tab_config.dart';
import 'route_extensions.dart';
import 'mapper.dart';

@Injectable(as: PBAppNavigator)
class AppRotuerImplementation implements PBAppNavigator {
  static final _globalNavigationKey = GlobalKey<NavigatorState>();

  late final AppRouter appRouter;

  @override
  Future<void> init({
    String? initialLocationName,
    List<NavigatorObserver> observers = const [],
  }) {
    final sharedRoutes = SharedRoutes(_globalNavigationKey);
    final tabConfig = TabConfig();
    appRouter = AppRouter(
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
      initialLocationName: initialLocationName,
      observers: observers,
    );
    return SynchronousFuture(null);
  }

  Future<T?> go<T extends Object?>(
    String location, {
    Object? extra,
    bool backToCaller = false,
  }) {
    return appRouter.go<T>(
      location,
      backToCaller: backToCaller,
      extra: extra,
    );
  }

  @override
  Future<T?> goNamed<T extends Object?>(
    String name, {
    Object? extra,
    bool backToCaller = false,
  }) {
    return appRouter.goNamed<T>(
      name,
      backToCaller: backToCaller,
      extra: extra,
    );
  }

  @override
  void pop<T extends Object?>([T? result]) {
    return appRouter.pop<T>(result);
  }

  Future<T?> push<T extends Object?>(
    String location, {
    Object? extra,
  }) {
    return appRouter.push<T>(
      location,
      extra: extra,
    );
  }

  @override
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  }) {
    return appRouter.pushNamed(
      name,
      extra: extra,
    );
  }

  @override
  PBRouteLocation? get currentLocation =>
      appRouter.currentLocation?.mapToPBRouteLocation();

  @override
  Widget getAppWidget({
    ThemeData? materialThemeData,
    CupertinoThemeData? cupertinoThemeData,
    List<Locale> supportedLocales = const <Locale>[Locale('en', 'US')],
    Locale? locale,
    List<LocalizationsDelegate>? localizationsDelegates,
    String title = '',
    bool useInheritedMediaQuery = false,
  }) {
    return CupertinoApp.router(
      routeInformationParser: appRouter.routeInformationParser,
      routerDelegate: appRouter.routerDelegate,
      backButtonDispatcher: appRouter.backButtonDispatcher,
      routeInformationProvider: appRouter.routeInformationProvider,
      supportedLocales: supportedLocales,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      title: title,
      theme: cupertinoThemeData,
      useInheritedMediaQuery: useInheritedMediaQuery,
      debugShowCheckedModeBanner: false,
    );
  }
}
