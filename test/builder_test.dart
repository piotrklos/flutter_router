import "package:app_router/app_router.dart";
import "package:app_router/src/builder.dart";
import "package:app_router/src/configuration.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import 'helper/sample_pages.dart';

void main() {
  testWidgets("Builds AppRoute", (WidgetTester tester) async {
    final config = AppRouterConfiguration(
      topLevelRoutes: [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (_, __) {
            return _DetailsScreen();
          },
        ),
      ],
      globalNavigatorKey: GlobalKey<NavigatorState>(),
    );

    final routerPaths = RouterPaths([
      FoundRoute.test(
        route: config.topLevelRoutes.first,
        extra: null,
        fullPath: "/",
      ),
    ]);

    await tester.pumpWidget(
      _BuilderTestWidget(
        routeConfiguration: config,
        routerPaths: routerPaths,
      ),
    );

    expect(find.byType(_DetailsScreen), findsOneWidget);
  });

  testWidgets("Builds ShellRoute", (WidgetTester tester) async {
    final config = AppRouterConfiguration(
      topLevelRoutes: [
        ShellRoute(
          builder: (_, __, child) {
            return child;
          },
          routes: [
            AppPageRoute(
              path: "/",
              name: "start",
              builder: (_, __) {
                return _DetailsScreen();
              },
            ),
          ],
        ),
      ],
      globalNavigatorKey: GlobalKey<NavigatorState>(),
    );

    final routerPaths = RouterPaths([
      FoundRoute.test(
        route: config.topLevelRoutes.first,
        fullPath: "",
        extra: null,
      ),
      FoundRoute.test(
        route: config.topLevelRoutes.first.routes.first,
        fullPath: "/",
        extra: null,
      ),
    ]);

    await tester.pumpWidget(
      _BuilderTestWidget(
        routeConfiguration: config,
        routerPaths: routerPaths,
      ),
    );

    expect(find.byType(_DetailsScreen), findsOneWidget);
  });

  testWidgets("Builds MultiShellRoute", (WidgetTester tester) async {
    final key = GlobalKey<NavigatorState>();
    final router = AppRouter(
      initialLocation: "/nested",
      errorBuilder: (_, __) => const ErrorScreen(message: ""),
      routes: [
        MultiShellRoute.stackedNavigationShell(
          stackItems: [
            StackedNavigationItem(
              navigatorKey: key,
              rootRouteLocation: const AppRouterLocation(
                name: "nested",
                path: "/nested",
              ),
            ),
          ],
          routes: [
            AppPageRoute(
              parentNavigatorKey: key,
              path: "/nested",
              name: "nested",
              builder: (_, __) {
                return _DetailsScreen();
              },
            ),
          ],
        ),
      ],
      navigatorKey: GlobalKey<NavigatorState>(),
    );

    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      backButtonDispatcher: router.backButtonDispatcher,
      routeInformationProvider: router.routeInformationProvider,
    ));

    await tester.pumpAndSettle();

    expect(find.byType(_DetailsScreen), findsOneWidget);
    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets("Uses the correct navigatorKey", (WidgetTester tester) async {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final config = AppRouterConfiguration(
      globalNavigatorKey: rootNavigatorKey,
      topLevelRoutes: [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (_, __) {
            return _DetailsScreen();
          },
        ),
      ],
    );

    final routerPaths = RouterPaths([
      FoundRoute.test(
        route: config.topLevelRoutes.first,
        fullPath: "/",
        extra: null,
      ),
    ]);

    await tester.pumpWidget(
      _BuilderTestWidget(
        routeConfiguration: config,
        routerPaths: routerPaths,
      ),
    );

    expect(find.byKey(rootNavigatorKey), findsOneWidget);
  });

  testWidgets("Builds a Navigator for ShellRoute", (WidgetTester tester) async {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();
    final config = AppRouterConfiguration(
      globalNavigatorKey: rootNavigatorKey,
      topLevelRoutes: [
        ShellRoute(
          builder: (_, __, Widget child) {
            return _HomeScreen(
              child: child,
            );
          },
          navigatorKey: shellNavigatorKey,
          routes: [
            AppPageRoute(
              path: "/details",
              name: "details",
              builder: (_, __) {
                return _DetailsScreen();
              },
            ),
          ],
        ),
      ],
    );

    final routerPaths = RouterPaths([
      FoundRoute.test(
        route: config.topLevelRoutes.first,
        fullPath: "",
        extra: null,
      ),
      FoundRoute.test(
        route: config.topLevelRoutes.first.routes.first,
        fullPath: "/details",
        extra: null,
      ),
    ]);

    await tester.pumpWidget(
      _BuilderTestWidget(
        routeConfiguration: config,
        routerPaths: routerPaths,
      ),
    );

    expect(find.byType(_HomeScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(_DetailsScreen), findsOneWidget);
    expect(find.byKey(rootNavigatorKey), findsOneWidget);
    expect(find.byKey(shellNavigatorKey), findsOneWidget);
  });

  testWidgets("Builds a Navigator for ShellRoute with parentNavigatorKey",
      (WidgetTester tester) async {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();

    final config = AppRouterConfiguration(
      globalNavigatorKey: rootNavigatorKey,
      topLevelRoutes: [
        ShellRoute(
          builder: (_, __, Widget child) {
            return _HomeScreen(
              child: child,
            );
          },
          navigatorKey: shellNavigatorKey,
          routes: [
            AppPageRoute(
              path: "/a",
              name: "a",
              builder: (_, __) {
                return _DetailsScreen();
              },
              routes: [
                AppPageRoute(
                  path: "details",
                  name: "details",
                  builder: (_, __) {
                    return _DetailsScreen();
                  },
                  parentNavigatorKey: rootNavigatorKey,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final routerPaths = RouterPaths([
      FoundRoute.test(
        route: config.topLevelRoutes.first.routes.first,
        fullPath: "/a/details",
        extra: null,
      ),
    ]);

    await tester.pumpWidget(
      _BuilderTestWidget(
        routeConfiguration: config,
        routerPaths: routerPaths,
      ),
    );

    expect(find.byType(_HomeScreen), findsNothing);
    expect(find.byType(_DetailsScreen), findsOneWidget);
  });
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Text("Home Screen"),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Details Screen"),
    );
  }
}

class _BuilderTestWidget extends StatelessWidget {
  _BuilderTestWidget({
    required this.routeConfiguration,
    required this.routerPaths,
  }) : builder = _routeBuilder(routeConfiguration);

  final AppRouterConfiguration routeConfiguration;
  final AppRouterBuilder builder;
  final RouterPaths routerPaths;

  /// Builds a [RouteBuilder] for tests
  static AppRouterBuilder _routeBuilder(AppRouterConfiguration configuration) {
    return AppRouterBuilder(
      configuration: configuration,
      builderWithNavigator: (_, __, navigator) {
        return navigator;
      },
      errorBuilder: (BuildContext context, AppRouterPageState state) {
        return Text("Error: ${state.exception}");
      },
      restorationScopeId: null,
      observers: <NavigatorObserver>[],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: builder.tryBuild(
        context: context,
        routerPaths: routerPaths,
        onPop: (_) {},
        navigatorKey: routeConfiguration.globalNavigatorKey,
      ),
    );
  }
}
