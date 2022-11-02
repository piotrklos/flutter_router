import 'package:app_router/app_router.dart';
import "package:app_router/information_parser.dart";
import 'package:equatable/equatable.dart';
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  Future<AppRouteInformationParser> _createParser(
    WidgetTester tester, {
    required List<BaseAppRoute> routes,
  }) async {
    final AppRouter router = AppRouter(
      routes: routes,
      errorBuilder: (ctx, _) => const SizedBox.shrink(),
    );
    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    ));
    return router.routeInformationParser;
  }

  final sampleRoutes = [
    AppPageRoute(
      path: "/",
      name: "start",
      builder: (_, __) => const SizedBox.shrink(),
      routes: [
        AppPageRoute(
          path: "a",
          name: "a",
          builder: (_, __) => const SizedBox.shrink(),
        ),
      ],
    ),
  ];

  testWidgets("AppRouteInformationParser can parse route", (
    WidgetTester tester,
  ) async {
    final parser = await _createParser(tester, routes: sampleRoutes);

    var routerPaths = await parser.parseRouteInformation(
      const RouteInformation(location: "/"),
    );
    var foundRoutes = routerPaths.routes;
    expect(foundRoutes.length, 1);
    expect(foundRoutes[0].extra, isNull);
    expect(foundRoutes[0].fullPath, "/");
    expect(foundRoutes[0].route, sampleRoutes[0]);

    const extra = _TestObject();
    routerPaths = await parser.parseRouteInformation(
      const RouteInformation(location: "/a", state: extra),
    );
    foundRoutes = routerPaths.routes;
    expect(foundRoutes.length, 2);
    expect(foundRoutes[0].extra, extra);
    expect(foundRoutes[0].fullPath, "/");
    expect(foundRoutes[0].route, sampleRoutes[0]);

    expect(foundRoutes[1].extra, extra);
    expect(foundRoutes[1].fullPath, "/a");
    expect(foundRoutes[1].route, sampleRoutes[0].routes[0]);
  });

  testWidgets("AppRouteInformationParser should return error on unknown route",
      (WidgetTester tester) async {
    final parser = await _createParser(
      tester,
      routes: sampleRoutes,
    );

    var routerPaths = await parser.parseRouteInformation(
      const RouteInformation(location: "/errorPath"),
    );

    var foundRoutes = routerPaths.routes;
    expect(foundRoutes.length, 1);
    expect(foundRoutes[0].extra, isNull);
    expect(foundRoutes[0].fullPath, "/errorPath");
    expect(
      foundRoutes[0].exception!.toString(),
      "Exception: no routes for location: /errorPath!",
    );
  });

  group("skip", () {
    group("skip to child", () {
      testWidgets("AppRouteInformationParser should skip child",
          (WidgetTester tester) async {
        final bRoute = AppPageRoute(
          path: "b",
          name: "b",
          builder: (_, __) => const SizedBox.shrink(),
        );
        final routes = [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const SizedBox.shrink(),
            routes: [
              AppPageRoute(
                path: "a",
                name: "a",
                builder: (_, __) => const SizedBox.shrink(),
                skip: (_) async {
                  return SkipOption.goToChild;
                },
                routes: [
                  bRoute,
                ],
              ),
            ],
          ),
        ];
        final parser = await _createParser(
          tester,
          routes: routes,
        );

        var routerPaths = await parser.parseRouteInformation(
          const RouteInformation(location: "/a/b"),
        );
        var foundRoutes = routerPaths.routes;

        expect(foundRoutes.length, 2);
        expect(foundRoutes[0].extra, isNull);
        expect(foundRoutes[0].fullPath, "/");
        expect(foundRoutes[0].route, routes[0]);

        expect(foundRoutes[1].extra, isNull);
        expect(foundRoutes[1].fullPath, "/a/b");
        expect(foundRoutes[1].route, bRoute);
      });

      testWidgets("AppRouteInformationParser should skip to child ",
          (WidgetTester tester) async {
        final aRoute = AppPageRoute(
          path: "a",
          name: "a",
          builder: (_, __) => const SizedBox.shrink(),
        );
        final routes = [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const SizedBox.shrink(),
            skip: (_) async {
              return SkipOption.goToChild;
            },
            routes: [aRoute],
          ),
        ];
        final parser = await _createParser(
          tester,
          routes: routes,
        );

        var routerPaths = await parser.parseRouteInformation(
          const RouteInformation(location: "/"),
        );
        var foundRoutes = routerPaths.routes;

        expect(foundRoutes.length, 1);
        expect(foundRoutes[0].extra, isNull);
        expect(foundRoutes[0].fullPath, "/a");
        expect(foundRoutes[0].route, aRoute);
      });

      testWidgets(
          "AppRouteInformationParser should throw an Exception when last route had skip to child ",
          (WidgetTester tester) async {
        final routes = [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const SizedBox.shrink(),
            routes: [
              AppPageRoute(
                path: "a",
                name: "a",
                builder: (_, __) => const SizedBox.shrink(),
                skip: (_) async {
                  return SkipOption.goToChild;
                },
              ),
            ],
          ),
        ];
        final parser = await _createParser(
          tester,
          routes: routes,
        );

        var routerPaths = await parser.parseRouteInformation(
          const RouteInformation(location: "/a"),
        );
        var foundRoutes = routerPaths.routes;

        expect(foundRoutes.length, 1);
        expect(foundRoutes[0].extra, isNull);
        expect(foundRoutes[0].fullPath, "/a");
        expect(
          foundRoutes[0].exception!.toString(),
          "AppRouterException: Child route can not be empty!",
        );
      });
    });

    group("skip to parent", () {
      testWidgets("AppRouteInformationParser should skip child",
          (WidgetTester tester) async {
        final bRoute = AppPageRoute(
          path: "b",
          name: "b",
          builder: (_, __) => const SizedBox.shrink(),
        );
        final routes = [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const SizedBox.shrink(),
            routes: [
              AppPageRoute(
                path: "a",
                name: "a",
                builder: (_, __) => const SizedBox.shrink(),
                skip: (_) async {
                  return SkipOption.goToParent;
                },
                routes: [
                  bRoute,
                ],
              ),
            ],
          ),
        ];
        final parser = await _createParser(
          tester,
          routes: routes,
        );

        var routerPaths = await parser.parseRouteInformation(
          const RouteInformation(location: "/a/b"),
        );
        var foundRoutes = routerPaths.routes;

        expect(foundRoutes.length, 2);
        expect(foundRoutes[0].extra, isNull);
        expect(foundRoutes[0].fullPath, "/");
        expect(foundRoutes[0].route, routes[0]);

        expect(foundRoutes[1].extra, isNull);
        expect(foundRoutes[1].fullPath, "/a/b");
        expect(foundRoutes[1].route, bRoute);
      });

      testWidgets("AppRouteInformationParser should skip to parent ",
          (WidgetTester tester) async {
        final routes = [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const SizedBox.shrink(),
            routes: [
              AppPageRoute(
                path: "a",
                name: "a",
                builder: (_, __) => const SizedBox.shrink(),
                skip: (_) async {
                  return SkipOption.goToParent;
                },
              ),
            ],
          ),
        ];
        final parser = await _createParser(
          tester,
          routes: routes,
        );

        var routerPaths = await parser.parseRouteInformation(
          const RouteInformation(location: "/a"),
        );
        var foundRoutes = routerPaths.routes;

        expect(foundRoutes.length, 1);
        expect(foundRoutes[0].extra, isNull);
        expect(foundRoutes[0].fullPath, "/");
        expect(foundRoutes[0].route, routes[0]);
      });

      testWidgets(
          "AppRouteInformationParser should throw an Exception when fist route had skip to parent ",
          (WidgetTester tester) async {
        final routes = [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const SizedBox.shrink(),
            skip: (_) async {
              return SkipOption.goToParent;
            },
          ),
        ];
        final parser = await _createParser(
          tester,
          routes: routes,
        );

        var routerPaths = await parser.parseRouteInformation(
          const RouteInformation(location: "/"),
        );
        var foundRoutes = routerPaths.routes;

        expect(foundRoutes.length, 1);
        expect(foundRoutes[0].extra, isNull);
        expect(foundRoutes[0].fullPath, "/");
        expect(
          foundRoutes[0].exception!.toString(),
          "AppRouterException: Top route can not skip to parent!",
        );
      });
    });
  });

  testWidgets("Creates a routers for ShellRoute", (WidgetTester tester) async {
    final List<BaseAppRoute> routes = [
      ShellRoute(
        builder: (_, __, child) {
          return Scaffold(
            body: child,
          );
        },
        routes: [
          AppPageRoute(
            path: "/a",
            name: "a",
            builder: (_, __) {
              return const SizedBox.shrink();
            },
          ),
          AppPageRoute(
            path: "/b",
            name: "b",
            builder: (_, __) {
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    ];

    final parser = await _createParser(
      tester,
      routes: routes,
    );

    var routerPaths = await parser.parseRouteInformation(
      const RouteInformation(location: "/a"),
    );

    var foundRoutes = routerPaths.routes;

    expect(foundRoutes, hasLength(2));
    expect(foundRoutes.first.exception, isNull);
  });
}

class _TestObject extends Equatable {
  final String message;

  const _TestObject({
    this.message = "",
  });

  @override
  List<Object?> get props => [message];
}
