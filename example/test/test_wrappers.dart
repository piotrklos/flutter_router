import 'package:example/app_router/implementation/mock/app_router_impl.dart';
import 'package:example/app_router/interface/inherited_router.dart';
import 'package:example/app_router/interface/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestWrappers {
  static Future<Widget> preparePageWrapperWithaNavigator({
    required String pageName,
    NavigatorObserver? observer,
    List<IRoute> routes = const [],
  }) {
    return _prepareAppWithNavigator(
      pageName: pageName,
      observer: observer,
      routes: routes,
    );
  }

  static Future<Widget> preparePageWrapperWithaNavigatorAndBlocs({
    required String pageName,
    required List<BlocProvider<BlocBase<Object?>>> providers,
    NavigatorObserver? observer,
    List<IRoute> routes = const [],
  }) {
    return _prepareAppWithNavigator(
      pageName: pageName,
      observer: observer,
      providers: providers,
      routes: routes,
    );
  }

  static Future<Widget> _prepareAppWithNavigator({
    required String pageName,
    bool useInheritedMediaQuery = false,
    NavigatorObserver? observer,
    List<BlocProvider<BlocBase<Object?>>> providers = const [],
    List<IRoute> routes = const [],
  }) async {
    final router = AppRotuerMockImplementation(
      routes: routes,
    );
    await router.init(
      observers: observer != null ? [observer] : [],
      initialLocationName: pageName,
    );
    final app = InheritedPBAppRouter(
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
    if (providers.isNotEmpty) {
      return MultiBlocProvider(providers: providers, child: app);
    }
    return app;
  }
}
