import 'package:app_router/configuration.dart';
import 'package:app_router/route.dart';
import 'package:app_router/route_finder.dart';
import 'package:app_router/router_exception.dart';
import 'package:app_router/router_skipper.dart';
import 'package:app_router/typedef.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper/helper.dart';

void main() {
  AppRouterSkipper _createSkipper({
    required List<BaseAppRoute> routes,
  }) {
    final configuration = AppRouterConfiguration(
      topLevelRoutes: routes,
      globalNavigatorKey: GlobalKey(),
    );
    return AppRouterSkipper(
      configuration,
    );
  }

  group("getSkipper", () {
    final cRoute = AppPageRoute(
      path: "c",
      name: "c",
      builder: (_, __) => const SizedBox.shrink(),
    );

    final bRoute = AppPageRoute(
      path: "b",
      name: "b",
      builder: (_, __) => const SizedBox.shrink(),
      skip: (_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return SkipOption.goToChild;
      },
      routes: [cRoute],
    );

    final aRoute = AppPageRoute(
      path: "a",
      name: "a",
      builder: (_, __) => const SizedBox.shrink(),
      skip: (_) {
        return Future.value(SkipOption.goToParent);
      },
      routes: [bRoute],
    );

    final startRoute = AppPageRoute(
      path: "/",
      name: "start",
      builder: (_, __) => const SizedBox.shrink(),
      routes: [
        aRoute,
      ],
    );
    final skipper = _createSkipper(routes: [startRoute]);

    test("should throw exception when index is negative value", () {
      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      expect(
        () => skipper.getSkipper(routerPaths, -1),
        throwsA(isA<RangeError>()),
      );
    });

    test("should throw exception when index is incorrect", () {
      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      expect(
        () => skipper.getSkipper(routerPaths, 4),
        throwsA(
          predicate(
            (e) =>
                e is AppRouterException &&
                e.message == 'Could not find route for index!',
          ),
        ),
      );
    });

    test("should return null", () async {
      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      final skipOption = await skipper.getSkipper(routerPaths, 0);
      expect(skipOption, null);
    });

    test("should return goToParent", () async {
      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      final skipOption = await skipper.getSkipper(routerPaths, 1);
      expect(skipOption, SkipOption.goToParent);
    });

    test("should return goToChild", () async {
      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      final skipOption = await skipper.getSkipper(routerPaths, 2);
      expect(skipOption, SkipOption.goToChild);
    });
  });

  group("processRouteLevelSkipper", () {
    test("Should return old RouterPaths if index in less than 0", () async {
      final bRoute = AppPageRoute(
        path: "b",
        name: "b",
        builder: (_, __) => const SizedBox.shrink(),
        skip: (_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return SkipOption.goToChild;
        },
      );
      final startRoute = AppPageRoute(
        path: "/",
        name: "start",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [bRoute],
      );
      final skipper = _createSkipper(routes: [startRoute]);

      final routerPaths = TestHelper.createRouterPaths([startRoute, bRoute]);

      final newRouterPaths = await skipper.processSkip(
        routerPaths,
        routeFinder: RouteFinder(skipper.configuration),
        index: -1,
      );
      expect(newRouterPaths, routerPaths);
    });

    test("Should return correct routerPaths with mixed skip option", () async {
      final cRoute = AppPageRoute(
        path: "c",
        name: "c",
        builder: (_, __) => const SizedBox.shrink(),
      );

      final bRoute = AppPageRoute(
        path: "b",
        name: "b",
        builder: (_, __) => const SizedBox.shrink(),
        skip: (_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return SkipOption.goToChild;
        },
        routes: [cRoute],
      );

      final aRoute = AppPageRoute(
        path: "a",
        name: "a",
        builder: (_, __) => const SizedBox.shrink(),
        skip: (_) {
          return Future.value(SkipOption.goToParent);
        },
        routes: [bRoute],
      );

      final startRoute = AppPageRoute(
        path: "/",
        name: "start",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [
          aRoute,
        ],
      );
      final skipper = _createSkipper(routes: [startRoute]);

      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      final newRouterPaths = await skipper.processSkip(
        routerPaths,
        routeFinder: RouteFinder(skipper.configuration),
        index: routerPaths.length - 1,
      );

      expect(
        newRouterPaths,
        RouterPaths([
          routerPaths.routeForIndex(0)!,
          routerPaths.routeForIndex(3)!,
        ]),
      );
    });

    test("Should return correct routerPaths without skip option", () async {
      final cRoute = AppPageRoute(
        path: "c",
        name: "c",
        builder: (_, __) => const SizedBox.shrink(),
      );

      final bRoute = AppPageRoute(
        path: "b",
        name: "b",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [cRoute],
      );

      final aRoute = AppPageRoute(
        path: "a",
        name: "a",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [bRoute],
      );

      final startRoute = AppPageRoute(
        path: "/",
        name: "start",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [
          aRoute,
        ],
      );
      final skipper = _createSkipper(routes: [startRoute]);
      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      final newRouterPaths = await skipper.processSkip(
        routerPaths,
        routeFinder: RouteFinder(skipper.configuration),
        index: routerPaths.length - 1,
      );

      expect(
        newRouterPaths,
        routerPaths,
      );
    });

    test("Should return correct routerPaths with last child skip option to parent",
        () async {
      final cRoute = AppPageRoute(
        path: "c",
        name: "c",
        builder: (_, __) => const SizedBox.shrink(),
        skip: (_) async {
          return SkipOption.goToParent;
        },
      );

      final bRoute = AppPageRoute(
        path: "b",
        name: "b",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [cRoute],
      );

      final aRoute = AppPageRoute(
        path: "a",
        name: "a",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [bRoute],
      );

      final startRoute = AppPageRoute(
        path: "/",
        name: "start",
        builder: (_, __) => const SizedBox.shrink(),
        routes: [
          aRoute,
        ],
      );
      final skipper = _createSkipper(routes: [startRoute]);
      final routerPaths = TestHelper.createRouterPaths(
        [startRoute, aRoute, bRoute, cRoute],
      );

      final newRouterPaths = await skipper.processSkip(
        routerPaths,
        routeFinder: RouteFinder(skipper.configuration),
        index: routerPaths.length - 1,
      );

      expect(
        newRouterPaths,
        RouterPaths([
          routerPaths.routeForIndex(0)!,
          routerPaths.routeForIndex(1)!,
          routerPaths.routeForIndex(2)!,
        ]),
      );
    });
  });
}
