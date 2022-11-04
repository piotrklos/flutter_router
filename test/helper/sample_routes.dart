import 'dart:async';

import 'package:app_router/src/bloc_provider.dart';
import 'package:app_router/src/route.dart';
import 'package:app_router/src/typedef.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockCubitState {}

class _SampleCubit<T extends BlocBase> extends Cubit<MockCubitState>
    with AppRouterBlocProvider<T> {
  _SampleCubit() : super(MockCubitState());
}

class TestAppPage1Cubit extends _SampleCubit<TestAppPage1Cubit> {}

class TestAppPage2Cubit extends _SampleCubit<TestAppPage2Cubit> {}

class TestAppPage3Cubit extends _SampleCubit<TestAppPage3Cubit> {}

class TestTab1Cubit extends _SampleCubit<TestTab1Cubit> {}

class TestTab2Cubit extends _SampleCubit<TestTab2Cubit> {}

class TestTab3Cubit extends _SampleCubit<TestTab3Cubit> {}

class TestTab12Cubit extends _SampleCubit<TestTab12Cubit> {}

class TestTab23Cubit extends _SampleCubit<TestTab23Cubit> {}

class TestTabCubit extends _SampleCubit<TestTabCubit> {}

class TestAppPage1Child1Cubit extends _SampleCubit<TestAppPage1Child1Cubit> {}

class TestAppPage1Child2Cubit extends _SampleCubit<TestAppPage1Child2Cubit> {}

class TestAppPage2Child1Cubit extends _SampleCubit<TestAppPage2Child1Cubit> {}

class TestAppPage2Child2Cubit extends _SampleCubit<TestAppPage2Child2Cubit> {}

class TestAppPage3Child1Cubit extends _SampleCubit<TestAppPage3Child1Cubit> {}

class TestAppPage3Child2Cubit extends _SampleCubit<TestAppPage3Child2Cubit> {}

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

  static final shellRoute = StatefulShellRoute(
    builder: (_, __, child) => child,
    branches: [
      ShellRouteBranch(
        rootRoute: routePage1,
        providersBuilder: () => [
          TestTab1Cubit(),
          TestTab12Cubit(),
          TestTabCubit(),
        ],
      ),
      ShellRouteBranch(
        rootRoute: routePage2,
        providersBuilder: () => [
          TestTab2Cubit(),
          TestTab12Cubit(),
          TestTab23Cubit(),
          TestTabCubit(),
        ],
      ),
      ShellRouteBranch(
        rootRoute: routePage3,
        providersBuilder: () => [
          TestTab3Cubit(),
          TestTab23Cubit(),
          TestTabCubit(),
        ],
      ),
    ],
    onPop: () {
      _controller?.add("shellRoute onPop");
    },
  );

  static final routePage1 = _MockAppPageRoute(
    path: "/page1",
    name: "routePage1",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        TestAppPage1Cubit(),
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
        TestAppPage1Child1Cubit(),
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
        TestAppPage1Child2Cubit(),
      ];
    },
  );

  static final routePage2 = _MockAppPageRoute(
    path: "/page2",
    name: "routePage2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        TestAppPage2Cubit(),
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
        TestAppPage2Child1Cubit(),
      ];
    },
  );

  static final routePage2Child2 = _MockAppPageRoute(
    path: "child2",
    name: "routePage2Child2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        TestAppPage2Child2Cubit(),
      ];
    },
  );

  static final routePage3 = _MockAppPageRoute(
    path: "/page3",
    name: "routePage3",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        TestAppPage3Cubit(),
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
        TestAppPage3Child1Cubit(),
      ];
    },
  );

  static final routePage3Child2 = _MockAppPageRoute(
    path: "child2",
    name: "routePage3Child2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        TestAppPage3Child2Cubit(),
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
