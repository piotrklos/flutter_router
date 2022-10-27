import 'package:app_router/app_router_bloc_provider.dart';
import 'package:app_router/route.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

class SampleCubit1 extends Mock implements AppRouterBlocProvider {}

class SampleCubit2 extends Mock implements AppRouterBlocProvider {}

class SampleCubit3 extends Mock implements AppRouterBlocProvider {}

class SampleCubit4 extends Mock implements AppRouterBlocProvider {}

class SampleCubitChild1 extends Mock implements AppRouterBlocProvider {}

class SampleCubitChild2 extends Mock implements AppRouterBlocProvider {}

class SampleCubitChild3 extends Mock implements AppRouterBlocProvider {}

class SampleCubitChild4 extends Mock implements AppRouterBlocProvider {}

class SampleRoutes {
  static final startRoute = AppPageRoute(
    path: "/",
    name: "start",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        SampleCubit1(),
      ];
    },
    routes: [
      routePage1,
      routePage2,
    ],
  );

  static final routePage1 = AppPageRoute(
      path: "page1",
      name: "page1",
      builder: (_, __) => Container(),
      providersBuilder: (_) {
        return [
          SampleCubit2(),
        ];
      },
      routes: [
        routePage1Child1,
        routePage1Child2,
      ]);

  static final routePage1Child1 = AppPageRoute(
    path: "child1",
    name: "routePage1Child1",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        SampleCubitChild1(),
      ];
    },
  );

  static final routePage1Child2 = AppPageRoute(
    path: "child2",
    name: "routePage1Child2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        SampleCubitChild2(),
      ];
    },
  );

  static final routePage2 = AppPageRoute(
    path: "page2",
    name: "page2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        SampleCubit3(),
      ];
    },
    routes: [
      routePage2Child1,
      routePage2Child2,
    ],
  );

  static final routePage2Child1 = AppPageRoute(
    path: "child1",
    name: "routePage2Child1",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        SampleCubitChild3(),
      ];
    },
  );

  static final routePage2Child2 = AppPageRoute(
    path: "child2",
    name: "routePage2Child2",
    builder: (_, __) => Container(),
    providersBuilder: (_) {
      return [
        SampleCubitChild4(),
      ];
    },
  );
}
