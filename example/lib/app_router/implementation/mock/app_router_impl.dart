import 'package:app_router/app_router.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../pages/shared/error_page.dart';
import '../../interface/route.dart';
import '../../routes/shared_routes.dart';
import '../../routes/tabs/tab_config.dart';
import '../app_router_impl.dart';
import '../route_extensions.dart';

class AppRotuerMockImplementation extends AppRotuerImplementation {
  static final _globalNavigationKey = GlobalKey<NavigatorState>();
  final List<IRoute> routes;

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

    appRouter = AppRouter(
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
}
