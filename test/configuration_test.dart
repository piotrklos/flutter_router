import 'package:app_router/src/page_state.dart';
import 'package:app_router/src/configuration.dart';
import 'package:app_router/src/route.dart';
import 'package:app_router/src/router_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('throws assertion when has duplicated name', () {
    final root = GlobalKey<NavigatorState>();

    final topRoute = AppPageRoute(
      path: '/a',
      name: 'a',
      builder: _testScreenBuilder,
      routes: [
        AppPageRoute(builder: _testScreenBuilder, name: "b", path: "b"),
        AppPageRoute(builder: _testScreenBuilder, name: "a", path: "a"),
      ],
    );

    expect(
      () {
        AppRouterConfiguration(
          globalNavigatorKey: root,
          topLevelRoutes: [topRoute],
        );
      },
      throwsAssertionError,
    );
  });

  test('throws assertion when has duplicated name in Shell', () {
    final root = GlobalKey<NavigatorState>();

    final topRoute = AppPageRoute(
      path: '/a',
      name: 'a',
      builder: _testScreenBuilder,
      routes: [
        AppPageRoute(builder: _testScreenBuilder, name: "b", path: "b"),
        ShellRoute(builder: _testShellBuilder, routes: [
          AppPageRoute(builder: _testScreenBuilder, name: "a", path: "a"),
        ]),
      ],
    );

    expect(
      () {
        AppRouterConfiguration(
          globalNavigatorKey: root,
          topLevelRoutes: [topRoute],
        );
      },
      throwsAssertionError,
    );
  });

  test('Should create correct map', () {
    final root = GlobalKey<NavigatorState>();

    final topRoute = AppPageRoute(
      path: '/a',
      name: 'a',
      builder: _testScreenBuilder,
      routes: [
        AppPageRoute(builder: _testScreenBuilder, name: "b", path: "b"),
        ShellRoute(builder: _testShellBuilder, routes: [
          AppPageRoute(builder: _testScreenBuilder, name: "c", path: "c"),
        ]),
      ],
    );

    expect(
      AppRouterConfiguration(
        globalNavigatorKey: root,
        topLevelRoutes: [topRoute],
      ).nameToPathMap,
      {
        "a": "/a",
        "b": "/a/b",
        "c": "/a/c",
      },
    );
  });

  test('Should create correct map - test 2', () {
    final root = GlobalKey<NavigatorState>();

    final topRoute = AppPageRoute(
      path: '/a',
      name: 'a',
      builder: _testScreenBuilder,
      routes: [
        AppPageRoute(builder: _testScreenBuilder, name: "b", path: "b"),
        ShellRoute(builder: _testShellBuilder, routes: [
          AppPageRoute(builder: _testScreenBuilder, name: "c", path: "c"),
          AppPageRoute(
            builder: _testScreenBuilder,
            name: "d",
            path: "d",
            routes: [
              AppPageRoute(builder: _testScreenBuilder, name: "e", path: "e"),
            ],
          ),
        ]),
      ],
    );

    expect(
      AppRouterConfiguration(
        globalNavigatorKey: root,
        topLevelRoutes: [
          topRoute,
          AppPageRoute(builder: _testScreenBuilder, name: "f", path: "/f"),
        ],
      ).nameToPathMap,
      {
        "a": "/a",
        "b": "/a/b",
        "c": "/a/c",
        "d": "/a/d",
        "e": "/a/d/e",
        "f": "/f"
      },
    );
  });

  test('Should create correct map - with uppercased name', () {
    final root = GlobalKey<NavigatorState>();

    final topRoute = AppPageRoute(
      path: '/a',
      name: 'A',
      builder: _testScreenBuilder,
      routes: [
        AppPageRoute(builder: _testScreenBuilder, name: "B", path: "b"),
        ShellRoute(builder: _testShellBuilder, routes: [
          AppPageRoute(builder: _testScreenBuilder, name: "C", path: "c"),
        ]),
      ],
    );

    expect(
      AppRouterConfiguration(
        globalNavigatorKey: root,
        topLevelRoutes: [topRoute],
      ).nameToPathMap,
      {
        "a": "/a",
        "b": "/a/b",
        "c": "/a/c",
      },
    );
  });

  test('Should create correct map', () {
    final root = GlobalKey<NavigatorState>();

    final topRoute = AppPageRoute(
      path: '/a',
      name: 'a',
      builder: _testScreenBuilder,
      routes: [
        AppPageRoute(builder: _testScreenBuilder, name: "b", path: "b"),
        ShellRoute(builder: _testShellBuilder, routes: [
          AppPageRoute(builder: _testScreenBuilder, name: "c", path: "c"),
        ]),
      ],
    );

    expect(
      AppRouterConfiguration(
        globalNavigatorKey: root,
        topLevelRoutes: [topRoute],
      ).nameToPathMap,
      {
        "a": "/a",
        "b": "/a/b",
        "c": "/a/c",
      },
    );
  });

  group("getFullPathForName", () {
    final topRoute = AppPageRoute(
      path: '/a',
      name: 'start',
      builder: _testScreenBuilder,
      routes: [
        AppPageRoute(builder: _testScreenBuilder, name: "lowercase", path: "b"),
        ShellRoute(builder: _testShellBuilder, routes: [
          AppPageRoute(
              builder: _testScreenBuilder, name: "UPPERCASE", path: "c"),
          AppPageRoute(
            builder: _testScreenBuilder,
            name: "camelCase",
            path: "d",
            routes: [
              AppPageRoute(
                  builder: _testScreenBuilder, name: "snake_case", path: "e"),
            ],
          ),
        ]),
      ],
    );

    final configuration = AppRouterConfiguration(
      globalNavigatorKey: GlobalKey(),
      topLevelRoutes: [
        topRoute,
        AppPageRoute(builder: _testScreenBuilder, name: "end", path: "/f"),
      ],
    );

    test("Should throw exception for unkonown route", () {
      expect(
        () => configuration.getFullPathForName("test"),
        throwsA(
          predicate(
            (e) =>
                e is AppRouterException &&
                e.message == 'Unknown route name: test',
          ),
        ),
      );
    });

    test("Should return correct path '/a'", () {
      expect(
        configuration.getFullPathForName("start"),
        "/a",
      );
      expect(
        configuration.getFullPathForName("START"),
        "/a",
      );
      expect(
        configuration.getFullPathForName("Start"),
        "/a",
      );
    });

    test("Should return correct path '/f'", () {
      expect(
        configuration.getFullPathForName("end"),
        "/f",
      );
      expect(
        configuration.getFullPathForName("END"),
        "/f",
      );
    });

    test("Should return correct path '/a/c'", () {
      expect(
        configuration.getFullPathForName("UPPERCASE"),
        "/a/c",
      );
      expect(
        configuration.getFullPathForName("uppercase"),
        "/a/c",
      );
      expect(
        configuration.getFullPathForName("Uppercase"),
        "/a/c",
      );
    });

    test("Should return correct path '/a/d/e'", () {
      expect(
        configuration.getFullPathForName("snake_case"),
        "/a/d/e",
      );
      expect(
        configuration.getFullPathForName("SNAKE_CASE"),
        "/a/d/e",
      );
      expect(
        configuration.getFullPathForName("Snake_Case"),
        "/a/d/e",
      );
    });

    test("Should return correct path '/a/d'", () {
      expect(
        configuration.getFullPathForName("camelCase"),
        "/a/d",
      );
      expect(
        configuration.getFullPathForName("camelcase"),
        "/a/d",
      );
      expect(
        configuration.getFullPathForName("CAMELCASE"),
        "/a/d",
      );
    });
  });
}

class _TestScreen extends StatelessWidget {
  const _TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox();
}

Widget _testScreenBuilder(
  BuildContext context,
  AppRouterPageState state,
) {
  return _TestScreen(key: state.pageKey);
}

Widget _testShellBuilder(
  BuildContext context,
  AppRouterPageState state,
  Widget child,
) {
  return child;
}
