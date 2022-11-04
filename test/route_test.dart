import 'package:app_router/src/bloc_provider.dart';
import 'package:app_router/src/location.dart';
import 'package:app_router/src/route.dart';
import 'package:app_router/src/router_exception.dart';
import 'package:app_router/src/stacked_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCubit extends Mock implements AppRouterBlocProvider {}

void main() {
  group("isChild", () {
    test("Without Shell", () {
      final childChildRoute = AppPageRoute(
        name: "child2",
        builder: (_, __) => const SizedBox.shrink(),
        path: "child2",
      );
      final childRoute = AppPageRoute(
        name: "child",
        builder: (_, __) => const SizedBox.shrink(),
        path: "child",
        routes: [childChildRoute],
      );
      final rootRoute = AppPageRoute(
        name: "root",
        builder: (_, __) => const SizedBox.shrink(),
        path: "/",
        routes: [childRoute],
      );
      expect(rootRoute.isChild(childRoute), true);
      expect(rootRoute.isChild(childChildRoute), true);
      expect(childRoute.isChild(childChildRoute), true);

      expect(childRoute.isChild(rootRoute), false);
      expect(childChildRoute.isChild(rootRoute), false);
      expect(childChildRoute.isChild(childRoute), false);
    });

    test("With Shell", () {
      final childChildRoute = AppPageRoute(
        name: "child2",
        builder: (_, __) => const SizedBox.shrink(),
        path: "child2",
      );
      final childRoute = AppPageRoute(
        name: "child",
        builder: (_, __) => const SizedBox.shrink(),
        path: "/child",
        routes: [childChildRoute],
      );
      final otherRoute = AppPageRoute(
        name: "other",
        builder: (_, __) => const SizedBox.shrink(),
        path: "/other",
        routes: [childChildRoute],
      );
      final rootRoute = ShellRoute(
        builder: (_, __, ___) => const SizedBox.shrink(),
        routes: [childRoute, otherRoute],
      );
      expect(rootRoute.isChild(childRoute), true);
      expect(rootRoute.isChild(childChildRoute), true);
      expect(rootRoute.isChild(otherRoute), true);

      expect(childRoute.isChild(rootRoute), false);
      expect(otherRoute.isChild(rootRoute), false);
      expect(childRoute.isChild(otherRoute), false);
    });
  });

  group("AppPageRoute", () {
    test("Throw when name is null", () {
      expect(() {
        AppPageRoute(
          name: "",
          builder: (_, __) => const SizedBox.shrink(),
          path: "path",
        );
      }, throwsA(isAssertionError));
    });

    test("Throw when path is null", () {
      expect(() {
        AppPageRoute(
          name: "name",
          builder: (_, __) => const SizedBox.shrink(),
          path: "",
        );
      }, throwsA(isAssertionError));
    });

    test("Should not throw when path and name are provided ", () {
      AppPageRoute(
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
        path: "path",
      );
    });

    test("onPush without providers", () {
      var onPushCalled = false;
      final route = AppPageRoute(
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
        path: "path",
        onPush: () {
          onPushCalled = true;
        },
      );

      expect(route.providers, isEmpty);
      route.onPush(<T extends AppRouterBlocProvider>() {
        return null;
      });

      expect(onPushCalled, true);
      expect(route.providers, []);
    });
    test("onPush", () {
      var onPushCalled = false;
      final cubit = _MockCubit();
      final route = AppPageRoute(
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
        path: "path",
        onPush: () {
          onPushCalled = true;
        },
        providersBuilder: (_) {
          return [cubit];
        },
      );

      expect(route.providers, isEmpty);
      route.onPush(<T extends AppRouterBlocProvider>() {
        return null;
      });

      expect(onPushCalled, true);
      expect(route.providers, [cubit]);
    });

    test("onPop", () {
      var onPopCalled = false;
      final cubit = _MockCubit();
      final route = AppPageRoute(
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
        path: "path",
        onPop: () {
          onPopCalled = true;
        },
        providersBuilder: (_) {
          return [cubit];
        },
      );

      route.onPush(<T extends AppRouterBlocProvider>() {
        return null;
      });

      when(() => cubit.close()).thenAnswer((_) => Future.value(null));

      expect(route.providers, [cubit]);
      route.onPop();
      verify(() => cubit.close()).called(1);
      expect(route.providers, []);
      expect(onPopCalled, true);
    });

    test("onPop without providers", () {
      var onPopCalled = false;
      final route = AppPageRoute(
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
        path: "path",
        onPop: () {
          onPopCalled = true;
        },
      );

      route.onPop();
      expect(route.providers, []);
      expect(onPopCalled, true);
    });

    test("isContained", () {
      final route = AppPageRoute(
        name: "name",
        builder: (_, __) => const SizedBox.shrink(),
        path: "/path",
      );
      expect(route.isContained("/path"), true);
      expect(route.isContained("/path/test"), true);

      expect(route.isContained("/"), false);
      expect(route.isContained("/path1"), false);
      expect(route.isContained("/test"), false);
      expect(route.isContained("/pat"), false);
      expect(route.isContained("/path2/test"), false);
      expect(route.isContained("/path2/path/test"), false);
    });
  });

  group("ShellRoute", () {
    final pageRoute = AppPageRoute(
      name: "name",
      builder: (_, __) => const SizedBox.shrink(),
      path: "/",
    );

    test("Throw when routes is empty", () {
      expect(() {
        ShellRoute(
          routes: const [],
          builder: (_, __, ___) => const SizedBox.shrink(),
        );
      }, throwsA(isAssertionError));
    });

    test("Should not throw when routes is not empty", () {
      ShellRoute(
        routes: [pageRoute],
        builder: (_, __, ___) => const SizedBox.shrink(),
      );
    });

    test("Should throw when child key is different than shell key", () {
      expect(() {
        ShellRoute(
          routes: [
            AppPageRoute(
              name: "name",
              builder: (_, __) => const SizedBox.shrink(),
              path: "/",
              parentNavigatorKey: GlobalKey(),
            )
          ],
          builder: (_, __, ___) => const SizedBox.shrink(),
        );
      }, throwsA(isAssertionError));
    });

    test("Should return correct navigation key", () {
      final key = GlobalKey<NavigatorState>();
      final route = ShellRoute(
        routes: [pageRoute],
        builder: (_, __, ___) => const SizedBox.shrink(),
        navigatorKey: key,
      );
      expect(route.navigatorKey, key);
    });
  });

  group("MultiShellRoute", () {
    final pageRoute = AppPageRoute(
      name: "name",
      builder: (_, __) => const SizedBox.shrink(),
      path: "/",
    );

    test("Throw when routes is empty", () {
      expect(() {
        MultiShellRoute.stackedNavigationShell(
          stackItems: [
            StackedNavigationItem(
              navigatorKey: GlobalKey(),
              rootRouteLocation: const AppRouterLocation(path: "", name: ""),
            ),
          ],
          routes: const [],
        );
      }, throwsA(isAssertionError));
    });

    test("Throw when stackItems is empty", () {
      expect(() {
        MultiShellRoute.stackedNavigationShell(
          stackItems: const [],
          routes: [pageRoute],
        );
      }, throwsA(isAssertionError));
    });

    test("Should throw when child key is different than shell key", () {
      expect(() {
        MultiShellRoute.stackedNavigationShell(
          stackItems: [
            StackedNavigationItem(
              navigatorKey: GlobalKey(),
              rootRouteLocation: const AppRouterLocation(path: "", name: ""),
            ),
          ],
          routes: [
            AppPageRoute(
              name: "name",
              builder: (_, __) => const SizedBox.shrink(),
              path: "/",
              parentNavigatorKey: GlobalKey(),
            ),
          ],
        );
      }, throwsA(isAssertionError));
    });

    test("Should not throw when routes and stackItems are not empty", () {
      MultiShellRoute.stackedNavigationShell(
        stackItems: [
          StackedNavigationItem(
            navigatorKey: GlobalKey(),
            rootRouteLocation: const AppRouterLocation(path: "", name: ""),
          ),
        ],
        routes: [pageRoute],
      );
    });

    test("Should return correct navigation key", () {
      final key = GlobalKey<NavigatorState>();

      final route = MultiShellRoute.stackedNavigationShell(
        stackItems: [
          StackedNavigationItem(
            navigatorKey: key,
            rootRouteLocation: const AppRouterLocation(path: "", name: ""),
          ),
        ],
        routes: [pageRoute],
      );
      expect(route.navigatorKeyForChildRoute(pageRoute), key);
    });

    test("Should throw exception if route is not a child", () {
      final testPageRoute = AppPageRoute(
        name: "test",
        builder: (_, __) => const SizedBox.shrink(),
        path: "/test",
      );
      final route = MultiShellRoute.stackedNavigationShell(
        stackItems: [
          StackedNavigationItem(
            navigatorKey: GlobalKey(),
            rootRouteLocation: const AppRouterLocation(path: "", name: ""),
          ),
        ],
        routes: [pageRoute],
      );

      expect(
        () => route.navigatorKeyForChildRoute(testPageRoute),
        throwsA(const TypeMatcher<AppRouterException>()),
      );
    });
  });
}
