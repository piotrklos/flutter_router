import 'package:app_router/app_router.dart';
import 'package:app_router/src/configuration.dart';
import 'package:app_router/src/router_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper/helper.dart';
import 'helper/sample_routes.dart';

void main() {
  group("FoundRoute", () {
    test("Factory test - page route", () {
      final route = AppPageRoute(
        path: "/",
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
      );

      final result = FoundRoute.factory(
        route: route,
        fullpath: "/",
        remainPathToCheck: "/test/test2",
        extra: null,
      );

      expect(result, isNotNull);
      expect(result!.extra, isNull);
      expect(result.fullPath, "/");
      expect(result.route, route);
    });

    test("Factory test - page route - test 2", () {
      final route = AppPageRoute(
        path: "test",
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
      );

      final result = FoundRoute.factory(
        route: route,
        fullpath: "/test",
        remainPathToCheck: "test/test2",
        extra: null,
      );

      expect(result, isNotNull);
      expect(result!.extra, isNull);
      expect(result.fullPath, "/test");
      expect(result.route, route);
    });

    test("Factory test - invalid page route", () {
      final route = AppPageRoute(
        path: "test",
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
      );

      final result = FoundRoute.factory(
        route: route,
        fullpath: "/test",
        remainPathToCheck: "test2",
        extra: null,
      );

      expect(result, isNull);
    });

    test("Factory test - shell route", () {
      final route = AppPageRoute(
        path: "test",
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
      );
      final shellRoute = ShellRoute(
        builder: (_, __, ___) => const SizedBox.shrink(),
        routes: [route],
      );

      final result = FoundRoute.factory(
        route: shellRoute,
        fullpath: "/",
        remainPathToCheck: "/test/test2",
        extra: null,
      );

      expect(result, isNotNull);
      expect(result!.extra, isNull);
      expect(result.fullPath, "");
      expect(
        result.pageKey!.value,
        shellRoute.hashCode.toString(),
      );
      expect(result.route, shellRoute);
    });
  });

  group("RouterPaths", () {
    test("Empty RouterPaths", () {
      final routerPaths = RouterPaths.empty();
      expect(routerPaths.allRoutes, []);
      expect(routerPaths.isEmpty, true);
      expect(routerPaths.isNotEmpty, false);
      expect(routerPaths.shouldBackToParent, false);
      expect(routerPaths.parentRouterPaths, null);
      expect(routerPaths.containsAnyCubitProviders, false);
      expect(
        () => routerPaths.popLast(),
        throwsA(const TypeMatcher<AppRouterException>()),
      );
    });

    test("Should create correct", () {
      final foundRoutes = TestHelper.createFoundRoutes([
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1,
        SampleRoutes.routePage1Child1Child,
      ]);
      final routerPaths = RouterPaths(foundRoutes);
      expect(routerPaths.allRoutes, [
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1,
        SampleRoutes.routePage1Child1Child,
      ]);
      expect(routerPaths.isEmpty, false);
      expect(routerPaths.isNotEmpty, true);
      expect(routerPaths.shouldBackToParent, false);
      expect(routerPaths.parentRouterPaths, null);
      expect(
        routerPaths.location,
        const AppRouterLocation(
          name: "routePage1Child1Child",
          path: "/page1/child1/child1",
        ),
      );
      expect(routerPaths.extra, isNull);
      expect(routerPaths.length, 3);
      expect(
        routerPaths.last.route,
        SampleRoutes.routePage1Child1Child,
      );
      expect(
        routerPaths.routeForIndex(0)!.route,
        SampleRoutes.routePage1,
      );
      expect(routerPaths.routeForIndex(5), isNull);
      expect(
        routerPaths.firstAppRouteOfType<AppPageRoute>(),
        SampleRoutes.routePage1,
      );
      expect(
        routerPaths.parentsRoutesFor(foundRoutes[2]),
        [
          foundRoutes[0],
          foundRoutes[1],
        ],
      );
      expect(routerPaths.containsAnyCubitProviders, false);
    });

    group("pop", () {
      final foundRoutes = TestHelper.createFoundRoutes([
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1,
        SampleRoutes.routePage1Child1Child,
      ]);

      test("Should pop", () {
        final routerPaths = RouterPaths(foundRoutes);
        expect(routerPaths.length, 3);
        routerPaths.popLast();
        expect(routerPaths.length, 2);
      });

      test("Should throw error when router paths is empty", () {
        final routerPaths = RouterPaths.empty();
        expect(
          () => routerPaths.popLast(),
          throwsA(
            predicate(
              (e) =>
                  e is AppRouterException &&
                  e.message == 'You can not pop page off on the empty stack!',
            ),
          ),
        );
      });

      test("Should throw error when try pop last route", () {
        final routerPaths = RouterPaths(TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
        ]));
        expect(
          () => routerPaths.popLast(),
          throwsA(
            predicate(
              (e) =>
                  e is AppRouterException &&
                  e.message == 'You popped the last page off on the stack!',
            ),
          ),
        );
      });

      test("Should throw error when try pop last route with shell route", () {
        final routerPaths = RouterPaths(TestHelper.createFoundRoutes([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
        ]));
        expect(
          () => routerPaths.popLast(),
          throwsA(
            predicate(
              (e) =>
                  e is AppRouterException &&
                  e.message == 'You popped the last page off on the stack!',
            ),
          ),
        );
      });
    });

    group("firstAppRouteOfType", () {
      final baseShellRoute = ShellRoute(
        routes: [SampleRoutes.routePage1],
        builder: (_, __, child) => child,
      );
      test("Should find first AppPageRoute", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(
          routerPaths.firstAppRouteOfType<AppPageRoute>(),
          SampleRoutes.routePage1,
        );
      });

      test("Should find first ShellRouteBase", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);

        expect(
          routerPaths.firstAppRouteOfType<ShellRouteBase>(),
          SampleRoutes.shellRoute,
        );
      });

      test("Should find first ShellRoute", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.shellRoute,
          baseShellRoute,
          SampleRoutes.routePage1,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);

        expect(
          routerPaths.firstAppRouteOfType<MultiShellRoute>(),
          SampleRoutes.shellRoute,
        );
        expect(
          routerPaths.firstAppRouteOfType<ShellRoute>(),
          baseShellRoute,
        );
        expect(
          routerPaths.firstAppRouteOfType<ShellRouteBase>(),
          SampleRoutes.shellRoute,
        );
      });
    });

    group("firstAppPageRouteForShell", () {
      test("Should return null", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(
          routerPaths.firstAppPageRouteForShell(SampleRoutes.shellRoute),
          null,
        );
      });

      test("Should return SampleRoutes.startRoute", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(
          routerPaths.firstAppPageRouteForShell(SampleRoutes.shellRoute),
          SampleRoutes.routePage1,
        );
      });
    });

    test("Add new", () {
      var foundsRoutes = TestHelper.createFoundRoutes([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1,
      ]);
      final newRoute = foundsRoutes.removeLast();
      final routerPaths = RouterPaths(foundsRoutes.toList());
      expect(routerPaths.length, 2);
      expect(routerPaths.routes, foundsRoutes);
      routerPaths.addNew(newRoute);
      expect(routerPaths.length, 3);
      expect(routerPaths.routes, [...foundsRoutes, newRoute]);
    });

    test("Add new", () {
      var foundsRoutes = TestHelper.createFoundRoutes([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1,
      ]);
      final testPageRoute = AppPageRoute(
        builder: (_, __) => const SizedBox.shrink(),
        name: "test",
        path: "test",
      );
      final testFoundRoute = FoundRoute.test(
        route: testPageRoute,
        fullPath: "/page1/test",
      );
      final routerPaths = RouterPaths(foundsRoutes.toList());
      expect(routerPaths.last, foundsRoutes[2]);
      expect(routerPaths.routes, foundsRoutes);
      expect(routerPaths.length, 3);
      routerPaths.replaceLast(testFoundRoute);
      expect(routerPaths.length, 3);
      expect(routerPaths.last, testFoundRoute);
      expect(
        routerPaths.routes,
        TestHelper.createFoundRoutes([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
          testPageRoute,
        ]),
      );
    });

    group("parentsRoutesFor", () {
      test("Should return empty list - incorrect route", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
          SampleRoutes.routePage1Child1Child,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(
          routerPaths.parentsRoutesFor(
            FoundRoute.test(route: SampleRoutes.routePage1, fullPath: "/page2"),
          ),
          [],
        );
      });

      test("Should return empty list - first route", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
          SampleRoutes.routePage1Child1Child,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(
          routerPaths.parentsRoutesFor(foundsRoutes[0]),
          [],
        );
      });

      test("Should return correct list", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
          SampleRoutes.routePage1Child1Child,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(
          routerPaths.parentsRoutesFor(foundsRoutes[1]),
          [foundsRoutes[0]],
        );
      });

      test("Should return correct list - test 2", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
          SampleRoutes.routePage1Child1Child,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(routerPaths.parentsRoutesFor(foundsRoutes[2]), [
          foundsRoutes[0],
          foundsRoutes[1],
        ]);
      });
    });

    group("cubitGetter", () {
      test("Should return null", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
          SampleRoutes.routePage1Child1Child,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(routerPaths.cubitGetter<TestAppPage1Cubit>(), null);
      });

      test("Should return MockAppPage1Cubit", () {
        final cubit = TestAppPage1Cubit();
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1..addTempProvidersList([cubit]),
          SampleRoutes.routePage1Child1,
          SampleRoutes.routePage1Child1Child,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(routerPaths.cubitGetter<TestAppPage1Cubit>(), cubit);
        SampleRoutes.routePage1.clearProviders();
      });
    });

    group("containsAnyCubitProviders", () {
      test("Should return false", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(routerPaths.containsAnyCubitProviders, false);
      });

      test("Should return true", () {
        final foundsRoutes = TestHelper.createFoundRoutes([
          SampleRoutes.routePage1..addTempProvidersList([TestAppPage1Cubit()]),
          SampleRoutes.routePage1Child1,
        ]);
        final routerPaths = RouterPaths(foundsRoutes);
        expect(routerPaths.containsAnyCubitProviders, true);
      });
      SampleRoutes.routePage1.clearProviders();
    });
  });

  group("RouteFinder", () {
    RouteFinder _createRouteFinder({
      required List<BaseAppRoute> routes,
    }) {
      final configuration = AppRouterConfiguration(
        topLevelRoutes: routes,
        globalNavigatorKey: GlobalKey(),
      );
      return RouteFinder(configuration);
    }

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

    final shellRoute = ShellRoute(
      builder: (_, __, child) => child,
      routes: [
        startRoute,
      ],
    );

    group("proccessSkipToPaths", () {
      test("Should throw exception when index is greater than rotuters length",
          () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );

        expect(
          () {
            routeFinder.proccessSkipToPaths(
              routerPaths: TestHelper.createRouterPaths(
                [startRoute, aRoute, bRoute, cRoute],
              ),
              skipOption: SkipOption.goToChild,
              index: 4,
            );
          },
          throwsA(
            predicate(
              (e) =>
                  e is AppRouterException &&
                  e.message == 'Could not find route for index: 4!',
            ),
          ),
        );
      });

      test("Should return correct RouterPaths, index in the middle - goToChild",
          () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final foundsRoutes = TestHelper.createFoundRoutes(
          [startRoute, aRoute, bRoute, cRoute],
        );
        expect(
          routeFinder.proccessSkipToPaths(
            routerPaths: RouterPaths(foundsRoutes),
            skipOption: SkipOption.goToChild,
            index: 2,
          ),
          RouterPaths(foundsRoutes.toList()..removeAt(2)),
        );
      });

      test(
          "Should return correct RouterPaths, index in the middle - goToParent",
          () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final foundsRoutes = TestHelper.createFoundRoutes(
          [startRoute, aRoute, bRoute, cRoute],
        );
        expect(
          routeFinder.proccessSkipToPaths(
            routerPaths: RouterPaths(foundsRoutes),
            skipOption: SkipOption.goToParent,
            index: 2,
          ),
          RouterPaths(foundsRoutes.toList()..removeAt(2)),
        );
      });

      test("Should throw AppRouterException for index 0 - goToParent", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );

        expect(
          () {
            routeFinder.proccessSkipToPaths(
              routerPaths: TestHelper.createRouterPaths(
                [startRoute, aRoute],
              ),
              skipOption: SkipOption.goToParent,
              index: 0,
            );
          },
          throwsA(
            predicate(
              (e) =>
                  e is AppRouterException &&
                  e.message == 'Top route can not skip to parent!',
            ),
          ),
        );
      });

      test("Should return correct RouterPaths for index 1 - goToParent", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final foundsRoutes = TestHelper.createFoundRoutes(
          [startRoute, aRoute],
        );
        expect(
          routeFinder.proccessSkipToPaths(
            routerPaths: RouterPaths(foundsRoutes),
            skipOption: SkipOption.goToParent,
            index: 1,
          ),
          RouterPaths(
            TestHelper.createFoundRoutes([startRoute]),
          ),
        );
      });

      test(
          "Should throw AppRouterException when goToChild and child routes is empty",
          () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );

        expect(
          () {
            routeFinder.proccessSkipToPaths(
              routerPaths: TestHelper.createRouterPaths(
                [startRoute, aRoute, bRoute, cRoute],
              ),
              skipOption: SkipOption.goToChild,
              index: 3,
            );
          },
          throwsA(
            predicate(
              (e) =>
                  e is AppRouterException &&
                  e.message == 'Child route can not be empty!',
            ),
          ),
        );
      });

      test("Should return correct RouterPaths for index 1 - goToChild", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final foundsRoutes = TestHelper.createFoundRoutes(
          [startRoute, aRoute],
        );
        expect(
          routeFinder.proccessSkipToPaths(
            routerPaths: RouterPaths(foundsRoutes),
            skipOption: SkipOption.goToChild,
            index: 1,
          ),
          RouterPaths(
            TestHelper.createFoundRoutes(
              [startRoute, aRoute, bRoute],
            )..removeAt(1),
          ),
        );
      });

      test("Should return correct RouterPaths for index 0 - goToChild", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final foundsRoutes = TestHelper.createFoundRoutes(
          [startRoute],
        );
        expect(
          routeFinder.proccessSkipToPaths(
            routerPaths: RouterPaths(foundsRoutes),
            skipOption: SkipOption.goToChild,
            index: 0,
          ),
          RouterPaths(
            TestHelper.createFoundRoutes(
              [startRoute, aRoute],
            )..removeAt(0),
          ),
        );
      });
    });

    group("findForPath", () {
      test("Should throw exception for incorrect path", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );

        expect(
          () {
            routeFinder.findForPath("/b", shouldBackToParent: false);
          },
          throwsA(
            predicate(
              (e) =>
                  e is AppRouterException &&
                  e.message == 'No routes for path: /b',
            ),
          ),
        );
      });

      test("Should return correct RouterPath", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final result = routeFinder.findForPath("/", shouldBackToParent: false);
        expect(result, TestHelper.createRouterPaths([startRoute]));
      });

      test("Should return correct RouterPath - test2", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final result = routeFinder.findForPath("/a", shouldBackToParent: false);
        expect(result, TestHelper.createRouterPaths([startRoute, aRoute]));
      });

      test("Should return correct RouterPath - test 2", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final result = routeFinder.findForPath(
          "/a/b",
          shouldBackToParent: false,
        );
        expect(
          result,
          TestHelper.createRouterPaths(
            [startRoute, aRoute, bRoute],
          ),
        );
      });

      test("Should return correct RouterPath - test 3", () {
        final routeFinder = _createRouteFinder(
          routes: [startRoute],
        );
        final result = routeFinder.findForPath(
          "/a/b/c",
          shouldBackToParent: false,
        );
        expect(
          result,
          TestHelper.createRouterPaths(
            [startRoute, aRoute, bRoute, cRoute],
          ),
        );
      });

      group("With ShellRoute", () {
        test("Should return correct RouterPath", () {
          final routeFinder = _createRouteFinder(
            routes: [shellRoute],
          );
          final result = routeFinder.findForPath(
            "/a/b/c",
            shouldBackToParent: false,
          );
          expect(
            result,
            TestHelper.createRouterPaths(
              [shellRoute, startRoute, aRoute, bRoute, cRoute],
            ),
          );
        });

        test("Should return correct RouterPath - test 2", () {
          final routeFinder = _createRouteFinder(
            routes: [shellRoute],
          );
          final result = routeFinder.findForPath(
            "/",
            shouldBackToParent: false,
          );
          expect(
            result,
            TestHelper.createRouterPaths(
              [shellRoute, startRoute],
            ),
          );
        });

        test("Should return correct RouterPath - test 3", () {
          final route1 = AppPageRoute(
            path: "a",
            name: "a",
            builder: (_, __) => const SizedBox.shrink(),
          );

          final sampleShellRoute = ShellRoute(
            builder: (_, __, child) => child,
            routes: [
              route1,
            ],
          );
          final baseRoute = AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const SizedBox.shrink(),
            routes: [
              sampleShellRoute,
            ],
          );

          final routeFinder = _createRouteFinder(
            routes: [baseRoute],
          );
          final result = routeFinder.findForPath(
            "/a",
            shouldBackToParent: false,
          );
          expect(
            result,
            TestHelper.createRouterPaths(
              [baseRoute, sampleShellRoute, route1],
            ),
          );
        });
      });
    });
  });
}
