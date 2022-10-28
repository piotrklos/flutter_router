import 'package:example/app_router/implementation/app_router_impl.dart';
import 'package:example/app_router/interface/inherited_router.dart';
import 'package:flutter/material.dart';

class TestWrappers {
  static Future<Widget> preparePageWrapperWithaNavigator({
    required String pageName,
    NavigatorObserver? observer,
  }) {
    return _prepareAppWithNavigator(
      pageName: pageName,
      observer: observer,
    );
  }

  static Future<Widget> _prepareAppWithNavigator({
    required String pageName,
    bool useInheritedMediaQuery = false,
    NavigatorObserver? observer,
  }) async {
    final router = AppRotuerImplementation();
    await router.init(
      observers: observer != null ? [observer] : [],
      initialLocationName: pageName,
    );
    return InheritedPBAppRouter(
      appRouter: router,
      child: MaterialApp.router(
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        backButtonDispatcher: router.backButtonDispatcher,
        routeInformationProvider: router.routeInformationProvider,
        useInheritedMediaQuery: useInheritedMediaQuery,
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
