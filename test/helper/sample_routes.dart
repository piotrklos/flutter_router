import 'dart:async';

import 'package:app_router/app_router_bloc_provider.dart';
import 'package:app_router/app_router_location.dart';
import 'package:app_router/route.dart';
import 'package:app_router/stacked_navigation_shell.dart';
import 'package:app_router/typedef.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

class MockStartPageCubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage1Cubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage2Cubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage3Cubit extends Mock implements AppRouterBlocProvider {}

class MockTab1Cubit extends Mock implements AppRouterBlocProvider {}

class MockTab2Cubit extends Mock implements AppRouterBlocProvider {}

class MockTab3Cubit extends Mock implements AppRouterBlocProvider {}

class MockTab12Cubit extends Mock implements AppRouterBlocProvider {}

class MockTab23Cubit extends Mock implements AppRouterBlocProvider {}

class MockTabCubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage1Child1Cubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage1Child2Cubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage2Child1Cubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage2Child2Cubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage3Child1Cubit extends Mock implements AppRouterBlocProvider {}

class MockAppPage3Child2Cubit extends Mock implements AppRouterBlocProvider {}

class SampleRoutes {
  static StreamController<String>? _controller =
      StreamController<String>.broadcast();

  // static Stream<String>? get onPushPopStream => _controller?.stream;

  static setNewStreamController(StreamController<String> controller) {
    _controller = controller;
  }

  static clearStreamController() {
    _controller = null;
  }

  static final List<BaseAppRoute> sampleAppRouteWithStackedNavigation = [
    startRoute,
    shellRoute,
  ];

  static final shellRoute = MultiShellRoute.stackedNavigationShell(
    routes: [
      routePage1,
      routePage2,
      routePage3,
    ],
    onPop: () {
      _controller?.add("shellRoute onPop");
    },
    stackItems: [
      StackedNavigationItem(
        navigatorKey: GlobalKey<NavigatorState>(),
        rootRouteLocation: AppRouterLocation(
          name: routePage1.name,
          path: routePage1.path,
        ),
        providers: () => [
          MockTab1Cubit().blocProvider,
          MockTab12Cubit().blocProvider,
          MockTabCubit().blocProvider,
        ],
      ),
      StackedNavigationItem(
        navigatorKey: GlobalKey<NavigatorState>(),
        rootRouteLocation: AppRouterLocation(
          name: routePage2.name,
          path: routePage2.path,
        ),
        providers: () => [
          MockTab2Cubit().blocProvider,
          MockTab12Cubit().blocProvider,
          MockTab23Cubit().blocProvider,
          MockTabCubit().blocProvider,
        ],
      ),
      StackedNavigationItem(
        navigatorKey: GlobalKey<NavigatorState>(),
        rootRouteLocation: AppRouterLocation(
          name: routePage3.name,
          path: routePage3.path,
        ),
        providers: () => [
          MockTab3Cubit().blocProvider,
          MockTab23Cubit().blocProvider,
          MockTabCubit().blocProvider,
        ],
      ),
    ],
  );

  static final startRoute = _MockAppPageRoute(
    path: "/",
    name: "startRoute",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockStartPageCubit(),
      ];
    },
    routes: [
      routePage1,
      routePage2,
    ],
  );

  static final routePage1 = _MockAppPageRoute(
    path: "/page1",
    name: "routePage1",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage1Cubit(),
      ];
    },
    routes: [
      routePage1Child1,
      routePage1Child2,
    ],
  );

  static final routePage1Child1 = _MockAppPageRoute(
    path: "child1",
    name: "routePage1Child1",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage1Child1Cubit(),
      ];
    },
    routes: [
      routePage1Child1Child,
    ],
  );

  static final routePage1Child1Child = _MockAppPageRoute(
    path: "child1",
    name: "routePage1Child1Child",
    builder: (_, __) => Container(),
  );

  static final routePage1Child2 = _MockAppPageRoute(
    path: "child2",
    name: "routePage1Child2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage1Child2Cubit(),
      ];
    },
  );

  static final routePage2 = _MockAppPageRoute(
    path: "/page2",
    name: "routePage2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage2Cubit(),
      ];
    },
    routes: [
      routePage2Child1,
      routePage2Child2,
    ],
  );

  static final routePage2Child1 = _MockAppPageRoute(
    path: "child1",
    name: "routePage2Child1",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage2Child1Cubit(),
      ];
    },
  );

  static final routePage2Child2 = _MockAppPageRoute(
    path: "child2",
    name: "routePage2Child2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage2Child2Cubit(),
      ];
    },
  );

  static final routePage3 = _MockAppPageRoute(
    path: "/page3",
    name: "routePage3",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage3Cubit(),
      ];
    },
    routes: [
      routePage3Child1,
      routePage3Child2,
    ],
  );

  static final routePage3Child1 = _MockAppPageRoute(
    path: "child1",
    name: "routePage3Child1",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage3Child1Cubit(),
      ];
    },
  );

  static final routePage3Child2 = _MockAppPageRoute(
    path: "child2",
    name: "routePage3Child2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        MockAppPage3Child2Cubit(),
      ];
    },
  );
}

class _MockAppPageRoute extends AppPageRoute {
  _MockAppPageRoute({
    required String path,
    required String name,
    required AppRouterWidgetBuilder builder,
    List<BaseAppRoute> routes = const <BaseAppRoute>[],
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<AppRouterBlocProvider> Function(
      AppRouteProvidersBuilder cubitGetter,
    )?
        providersBuilder,
  }) : super(
          path: path,
          name: name,
          builder: builder,
          parentNavigatorKey: parentNavigatorKey,
          providersBuilder: providersBuilder,
          routes: routes,
        );

  @override
  void onPop() {
    SampleRoutes._controller?.add("$name onPop");
    super.onPop();
  }

  @override
  void onPush(AppRouteProvidersBuilder cubitGetter) {
    SampleRoutes._controller?.add("$name onPush");
    super.onPush(cubitGetter);
  }

  @override
  String toString() {
    return "AppPageRoute($name)";
  }
}
