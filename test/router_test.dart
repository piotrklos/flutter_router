import "package:app_router/app_router.dart";
import "package:app_router/src/context_extension.dart";
import "package:app_router/src/router_exception.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "helper/helper.dart";
import "helper/sample_cubit.dart";
import "helper/sample_pages.dart";

void main() {
  Future<AppRouter> _createRouter(
    List<BaseAppRoute> routes,
    WidgetTester tester, {
    String initialLocation = "/",
    String? initialNamedLocation,
    GlobalKey<NavigatorState>? navigatorKey,
    AppRouterWidgetBuilder? errorBuilder,
  }) async {
    final router = AppRouter(
      routes: routes,
      initialLocation: initialLocation,
      initialLocationName: initialNamedLocation,
      errorBuilder: errorBuilder ??
          (context, state) {
            return ErrorScreen(
              message: state.exception!.toString(),
            );
          },
      navigatorKey: navigatorKey,
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        backButtonDispatcher: router.backButtonDispatcher,
        routeInformationProvider: router.routeInformationProvider,
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  group("Validation", () {
    testWidgets("Should be a TestScreen", (WidgetTester tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (_, __) => const TestScreen(),
        ),
      ];

      final router = await _createRouter(routes, tester);
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes.length, 1);
      expect(foundRoutes.first.fullPath, "/");
      expect(find.byType(TestScreen), findsOneWidget);
    });

    testWidgets(
        "If there is more than one route with the same path, get first one", (
      WidgetTester tester,
    ) async {
      final routes = [
        AppPageRoute(path: "/", builder: testScreen, name: "first1"),
        AppPageRoute(path: "/", builder: testScreen, name: "first2"),
      ];

      final router = await _createRouter(routes, tester);
      router.go("/");
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes.length, 1);
      expect(foundRoutes.first.fullPath, "/");
      expect(foundRoutes.first.route.name, "first1");
      expect(find.byType(TestScreen), findsOneWidget);
    });

    testWidgets("lack of / on top-level route", (WidgetTester tester) async {
      final routes = [
        AppPageRoute(path: "test", name: "name", builder: testScreen),
      ];
      await expectLater(
        () async {
          await _createRouter(routes, tester);
        },
        throwsA(isAssertionError),
      );
    });
  });

  testWidgets("No routes founds - shoud find ErrorScreen",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(path: "/", name: "test", builder: testScreen),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/test");
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(foundRoutes.length, 1);
    expect(find.byType(ErrorScreen), findsOneWidget);
  });

  testWidgets("Shoud found 2nd top level route - StartScreen",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(path: "/", name: "home", builder: testScreen),
      AppPageRoute(path: "/start", name: "start", builder: startScreen),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/start");
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(foundRoutes.length, 1);
    expect(foundRoutes.first.fullPath, "/start");
    expect(find.byType(StartScreen), findsOneWidget);
  });

  testWidgets("Should found 2nd top level route with child routes",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(path: "/", name: "test", builder: testScreen, routes: [
        AppPageRoute(
          path: "page1",
          name: "page1",
          builder: (_, __) => const SamplePageScreen(),
        ),
      ]),
      AppPageRoute(path: "/start", name: "start", builder: startScreen),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/start");
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(foundRoutes.length, 1);
    expect(foundRoutes.first.fullPath, "/start");
    expect(find.byType(StartScreen), findsOneWidget);
  });

  testWidgets("Should found top level route when location has trailing /",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(path: "/", name: "test", builder: testScreen),
      AppPageRoute(path: "/start", name: "start", builder: startScreen),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/start/");
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(foundRoutes.length, 1);
    expect(foundRoutes.first.fullPath, "/start");
    expect(find.byType(StartScreen), findsOneWidget);
  });

  testWidgets("Should found route when location has trailing / and skip",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(
        path: "/start",
        name: "start",
        builder: startScreen,
        skip: (_) => SkipOption.goToChild,
        routes: [
          AppPageRoute(path: "test", name: "test", builder: testScreen),
        ],
      ),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/start/");
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(foundRoutes.length, 1);
    expect(foundRoutes.first.fullPath, "/start/test");
    expect(find.byType(TestScreen), findsOneWidget);
  });

  testWidgets("Get AppRouter parameters from builder",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(
        path: "/",
        name: "start",
        builder: (BuildContext context, _) {
          return SizedBox(
            child: Text(AppRouter.of(context).currentLocation?.name ?? ""),
          );
        },
      ),
      AppPageRoute(
        path: "/test",
        name: "test",
        builder: (BuildContext context, _) {
          return SizedBox(
            child: Text(AppRouter.of(context).currentLocation?.name ?? ""),
          );
        },
      ),
    ];

    final router = await _createRouter(routes, tester);
    expect(find.text("start"), findsOneWidget);
    router.go("/test");
    await tester.pumpAndSettle();
    expect(find.text("test"), findsOneWidget);
  });

  testWidgets("Get AppRouter parameters from error builder",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(path: "/", builder: testScreen, name: "test"),
    ];

    final router = await _createRouter(
      routes,
      tester,
      errorBuilder: (BuildContext context, _) {
        return Text(
          AppRouter.of(context).currentLocation?.path ?? "",
        );
      },
    );
    router.go("/abc");
    await tester.pumpAndSettle();
    expect(find.text("/abc"), findsOneWidget);
    router.go("/abcde");
    await tester.pumpAndSettle();
    expect(find.text("/abcde"), findsOneWidget);
  });

  testWidgets("Should get sub-routes correctly", (WidgetTester tester) async {
    final routes = [
      AppPageRoute(
        path: "/",
        name: "start",
        builder: startScreen,
        routes: [
          AppPageRoute(path: "test", name: "test", builder: testScreen),
        ],
      ),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/test");
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(foundRoutes.length, 2);
    expect(foundRoutes.first.fullPath, "/");
    expect(find.byType(StartScreen, skipOffstage: false), findsOneWidget);
    expect(foundRoutes[1].fullPath, "/test");
    expect(find.byType(TestScreen), findsOneWidget);
  });

  testWidgets("match sub-routes", (WidgetTester tester) async {
    final routes = [
      AppPageRoute(
        path: "/",
        name: "start",
        builder: startScreen,
        routes: [
          AppPageRoute(
            path: "family",
            name: "family",
            builder: (_, __) => const FamilyPage("family"),
            routes: [
              AppPageRoute(
                path: "person",
                name: "person",
                builder: (_, __) => const FamilyPeronsPage(
                  "family",
                  "person",
                ),
              ),
            ],
          ),
          AppPageRoute(
            path: "test",
            name: "test",
            builder: testScreen,
          ),
        ],
      ),
    ];

    final router = await _createRouter(routes, tester);
    {
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes.length, 1);
      expect(foundRoutes.first.fullPath, "/");
      expect(find.byType(StartScreen), findsOneWidget);
    }

    router.go("/test");
    await tester.pumpAndSettle();
    {
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes.length, 2);
      expect(foundRoutes.first.fullPath, "/");
      expect(find.byType(StartScreen, skipOffstage: false), findsOneWidget);
      expect(foundRoutes[1].fullPath, "/test");
      expect(find.byType(TestScreen), findsOneWidget);
    }

    router.go("/family");
    await tester.pumpAndSettle();
    {
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes.length, 2);
      expect(foundRoutes.first.fullPath, "/");
      expect(find.byType(StartScreen, skipOffstage: false), findsOneWidget);
      expect(foundRoutes[1].fullPath, "/family");
      expect(find.byType(FamilyPage), findsOneWidget);
    }

    router.go("/family/person");
    await tester.pumpAndSettle();
    {
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes.length, 3);
      expect(foundRoutes.first.fullPath, "/");
      expect(find.byType(StartScreen, skipOffstage: false), findsOneWidget);
      expect(foundRoutes[1].fullPath, "/family");
      expect(find.byType(FamilyPage, skipOffstage: false), findsOneWidget);
      expect(foundRoutes[2].fullPath, "/family/person");
      expect(find.byType(FamilyPeronsPage), findsOneWidget);
    }
  });

  testWidgets("Should return correct route if too many subroutes",
      (WidgetTester tester) async {
    final routes = [
      AppPageRoute(
        path: "/",
        name: "start",
        builder: startScreen,
        routes: [
          AppPageRoute(
            path: "family/page",
            name: "familyPage",
            builder: (_, __) => const FamilyPage(""),
          ),
          AppPageRoute(
            path: "abc",
            name: "abc",
            builder: (_, __) => const SamplePageScreen(),
          ),
          AppPageRoute(
            path: "familyPerson",
            name: "familyPerson",
            builder: (_, __) => const FamilyPeronsPage("", ""),
            routes: [
              AppPageRoute(path: "test", name: "test", builder: testScreen),
            ],
          ),
        ],
      ),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/abc");
    await tester.pumpAndSettle();
    {
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes, hasLength(2));
      expect(find.byType(SamplePageScreen), findsOneWidget);
    }

    router.go("/familyPerson/test");
    await tester.pumpAndSettle();
    {
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes, hasLength(3));
      expect(find.byType(TestScreen), findsOneWidget);
    }

    router.go("/familyPerson");
    await tester.pumpAndSettle();
    {
      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes, hasLength(2));
      expect(find.byType(FamilyPeronsPage), findsOneWidget);
    }
  });

  testWidgets("router state", (WidgetTester tester) async {
    final routes = [
      AppPageRoute(
        name: "start",
        path: "/",
        builder: (BuildContext context, AppRouterPageState state) {
          expect(state.fullpath, "/");
          expect(state.name, "start");
          expect(state.fullpath, "/");
          expect(state.exception, null);
          if (state.extra != null) {
            expect(state.extra! as int, 1);
          }
          return const StartScreen();
        },
        routes: [
          AppPageRoute(
            name: "test",
            path: "test",
            builder: (BuildContext context, AppRouterPageState state) {
              expect(state.name, "login");
              expect(state.fullpath, "/login");
              expect(state.exception, null);
              expect(state.extra! as int, 2);
              return const TestScreen();
            },
          ),
          AppPageRoute(
            name: "family",
            path: "family",
            builder: (BuildContext context, AppRouterPageState state) {
              expect(state.name, "family");
              expect(state.fullpath, "/family");
              expect(state.exception, null);
              expect(state.extra! as int, 3);
              return const FamilyPage("");
            },
            routes: [
              AppPageRoute(
                name: "person",
                path: "person",
                builder: (BuildContext context, AppRouterPageState state) {
                  expect(state.name, "person");
                  expect(state.fullpath, "/family/person");
                  expect(state.exception, null);
                  expect(state.extra! as int, 4);
                  return const FamilyPeronsPage("", "");
                },
              ),
            ],
          ),
        ],
      ),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/", extra: 1);
    await tester.pump();
    router.push("/test", extra: 2);
    await tester.pump();
    router.push("/family", extra: 3);
    await tester.pump();
    router.push("/family/person", extra: 4);
    await tester.pump();
  });

  testWidgets("match path case insensitively", (WidgetTester tester) async {
    final routes = [
      AppPageRoute(path: "/", name: "start", builder: startScreen),
      AppPageRoute(
        path: "/family",
        name: "family",
        builder: (_, __) => const FamilyPage(""),
      ),
    ];

    final router = await _createRouter(routes, tester);
    const String path = "/FaMiLy";
    router.go(path);
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(router.currentLocation!.path.toLowerCase(), path.toLowerCase());
    expect(foundRoutes, hasLength(1));
    expect(find.byType(FamilyPage), findsOneWidget);
  });

  testWidgets("If there is more than one route to match, use the first match.",
      (
    WidgetTester tester,
  ) async {
    final routes = [
      AppPageRoute(path: "/", name: "/start", builder: testScreen),
      AppPageRoute(path: "/page1", name: "page1", builder: testScreen),
      AppPageRoute(path: "/page1", name: "page1_copy", builder: startScreen),
    ];

    final router = await _createRouter(routes, tester);
    router.go("/page1");
    await tester.pumpAndSettle();
    final foundRoutes = router.routerDelegate.routerPaths.routes;
    expect(foundRoutes, hasLength(1));
    expect(find.byType(TestScreen), findsOneWidget);
  });

  group("Android back button", () {
    testWidgets("Handles the Android back button correctly",
        (WidgetTester tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (_, __) {
            return const Scaffold(
              body: Text("Screen A"),
            );
          },
          routes: [
            AppPageRoute(
              path: "b",
              name: "bScreen",
              builder: (_, __) {
                return const Scaffold(
                  body: Text("Screen B"),
                );
              },
            ),
          ],
        ),
      ];

      await _createRouter(routes, tester, initialLocation: "/b");
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen B"), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text("Screen A"), findsOneWidget);
      expect(find.text("Screen B"), findsNothing);
    });

    testWidgets("Handles the Android back button correctly with ShellRoute",
        (WidgetTester tester) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>();

      final List<BaseAppRoute> routes = [
        ShellRoute(
          builder: (_, __, Widget child) {
            return Scaffold(
              appBar: AppBar(title: const Text("Shell")),
              body: child,
            );
          },
          routes: [
            AppPageRoute(
              path: "/a",
              name: "aScreen",
              builder: (_, __) {
                return const Scaffold(body: Text("Screen A"));
              },
              routes: [
                AppPageRoute(
                  path: "b",
                  name: "bScreen",
                  builder: (_, __) {
                    return const Scaffold(body: Text("Screen B"));
                  },
                  routes: [
                    AppPageRoute(
                      path: "c",
                      name: "cScreen",
                      builder: (_, __) {
                        return const Scaffold(body: Text("Screen C"));
                      },
                      routes: [
                        AppPageRoute(
                          path: "d",
                          name: "dScreen",
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (_, __) {
                            return const Scaffold(body: Text("Screen D"));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ];

      await _createRouter(
        routes,
        tester,
        initialLocation: "/a/b/c/d",
        navigatorKey: rootNavigatorKey,
      );
      expect(find.text("Shell"), findsNothing);
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen B"), findsNothing);
      expect(find.text("Screen C"), findsNothing);
      expect(find.text("Screen D"), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text("Shell"), findsOneWidget);
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen B"), findsNothing);
      expect(find.text("Screen C"), findsOneWidget);
      expect(find.text("Screen D"), findsNothing);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.text("Shell"), findsOneWidget);
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen B"), findsOneWidget);
      expect(find.text("Screen C"), findsNothing);
    });

    testWidgets(
        "Handles the Android back button when parentNavigatorKey is set to the root navigator",
        (
      WidgetTester tester,
    ) async {
      final List<MethodCall> log = [];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      Future<void> verify(AsyncCallback test, List<Object> expectations) async {
        log.clear();
        await test();
        expect(log, expectations);
      }

      final rootNavigatorKey = GlobalKey<NavigatorState>();

      final routes = [
        AppPageRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: "/a",
          name: "aScreen",
          builder: (_, __) {
            return const Scaffold(body: Text("Screen A"));
          },
        ),
      ];

      await _createRouter(
        routes,
        tester,
        initialLocation: "/a",
        navigatorKey: rootNavigatorKey,
      );
      expect(find.text("Screen A"), findsOneWidget);

      await tester.runAsync(() async {
        await verify(() => simulateAndroidBackButton(tester), <Object>[
          isMethodCall("SystemNavigator.pop", arguments: null),
        ]);
      });
    });

    testWidgets("Handles the Android back button when ShellRoute can't pop",
        (WidgetTester tester) async {
      final List<MethodCall> log = [];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      Future<void> verify(AsyncCallback test, List<Object> expectations) async {
        log.clear();
        await test();
        expect(log, expectations);
      }

      final rootNavigatorKey = GlobalKey<NavigatorState>();

      final routes = [
        AppPageRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: "/a",
          name: "aScreen",
          builder: (_, __) {
            return const Scaffold(body: Text("Screen A"));
          },
        ),
        ShellRoute(
          builder: (_, __, Widget child) {
            return Scaffold(
              appBar: AppBar(title: const Text("Shell")),
              body: child,
            );
          },
          routes: [
            AppPageRoute(
              path: "/b",
              name: "bScreen",
              builder: (_, __) {
                return const Scaffold(body: Text("Screen B"));
              },
            ),
          ],
        ),
      ];

      await _createRouter(
        routes,
        tester,
        initialLocation: "/b",
        navigatorKey: rootNavigatorKey,
      );
      expect(find.text("Screen B"), findsOneWidget);

      await tester.runAsync(() async {
        await verify(() => simulateAndroidBackButton(tester), <Object>[
          isMethodCall("SystemNavigator.pop", arguments: null),
        ]);
      });
    });

    testWidgets(
        "Handles the Android back button when a second Shell has a AppRoute with parentNavigator key",
        (WidgetTester tester) async {
      final List<MethodCall> log = [];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      Future<void> verify(AsyncCallback test, List<Object> expectations) async {
        log.clear();
        await test();
        expect(log, expectations);
      }

      final rootNavigatorKey = GlobalKey<NavigatorState>();
      final shellNavigatorKeyA = GlobalKey<NavigatorState>();
      final shellNavigatorKeyB = GlobalKey<NavigatorState>();

      final routes = [
        ShellRoute(
          navigatorKey: shellNavigatorKeyA,
          builder: (_, __, Widget child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Shell"),
              ),
              body: child,
            );
          },
          routes: [
            AppPageRoute(
              path: "/a",
              name: "aScreem",
              builder: (_, __) {
                return const Scaffold(body: Text("Screen A"));
              },
              routes: [
                ShellRoute(
                  navigatorKey: shellNavigatorKeyB,
                  builder: (_, __, Widget child) {
                    return Scaffold(
                      appBar: AppBar(title: const Text("Shell")),
                      body: child,
                    );
                  },
                  routes: [
                    AppPageRoute(
                      path: "b",
                      name: "bScreen",
                      parentNavigatorKey: shellNavigatorKeyB,
                      builder: (_, __) {
                        return const Scaffold(body: Text("Screen B"));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ];

      await _createRouter(
        routes,
        tester,
        initialLocation: "/a/b",
        navigatorKey: rootNavigatorKey,
      );
      expect(find.text("Screen B"), findsOneWidget);

      // The first pop should not exit the app.
      await tester.runAsync(() async {
        await verify(() => simulateAndroidBackButton(tester), []);
      });

      // The second pop should exit the app.
      await tester.runAsync(() async {
        await verify(() => simulateAndroidBackButton(tester), [
          isMethodCall("SystemNavigator.pop", arguments: null),
        ]);
      });
    });
  });

  group("named routes", () {
    testWidgets("Should go home route", (WidgetTester tester) async {
      final routes = [
        AppPageRoute(name: "start", path: "/", builder: startScreen),
      ];

      final router = await _createRouter(routes, tester);
      router.goNamed("start");
      await tester.pumpAndSettle();
      expect(find.byType(StartScreen), findsOneWidget);
    });

    testWidgets("Should throw assertion error - duplicated name",
        (WidgetTester tester) async {
      final routes = [
        AppPageRoute(name: "start", path: "/", builder: startScreen),
        AppPageRoute(name: "start", path: "/", builder: startScreen),
      ];

      await expectLater(() async {
        await _createRouter(routes, tester);
      }, throwsA(isAssertionError));
    });

    test("Should throw assertion error - empty name", () {
      expect(() {
        AppPageRoute(name: "", path: "/", builder: startScreen);
      }, throwsA(isAssertionError));
    });

    testWidgets("Should throw assertion error - no found routes",
        (WidgetTester tester) async {
      await expectLater(
        () async {
          final routes = [
            AppPageRoute(name: "start", path: "/", builder: startScreen),
          ];
          final router = await _createRouter(routes, tester);
          router.goNamed("test");
        },
        throwsA(
          predicate(
            (e) =>
                e is AppRouterException &&
                e.message == "Unknown route name: test",
          ),
        ),
      );
    });

    testWidgets("Should find second top level route",
        (WidgetTester tester) async {
      final routes = [
        AppPageRoute(name: "start", path: "/", builder: startScreen),
        AppPageRoute(name: "test", path: "/test", builder: testScreen),
      ];

      final router = await _createRouter(routes, tester);
      router.goNamed("test");
      await tester.pumpAndSettle();
      expect(find.byType(TestScreen), findsOneWidget);
    });

    testWidgets("Should find sub-route", (WidgetTester tester) async {
      final List<AppPageRoute> routes = <AppPageRoute>[
        AppPageRoute(
          name: "start",
          path: "/",
          builder: startScreen,
          routes: <AppPageRoute>[
            AppPageRoute(name: "test", path: "test", builder: testScreen),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);
      router.goNamed("test");
      await tester.pumpAndSettle();
      expect(find.byType(TestScreen), findsOneWidget);
    });

    testWidgets("Shoud find case insensitive", (WidgetTester tester) async {
      final List<AppPageRoute> routes = <AppPageRoute>[
        AppPageRoute(
          name: "start",
          path: "/",
          builder: startScreen,
          routes: <AppPageRoute>[
            AppPageRoute(name: "FaMiLy", path: "family", builder: testScreen),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);
      router.goNamed("family");
      await tester.pumpAndSettle();
      expect(find.byType(TestScreen), findsOneWidget);
    });
  });

  group("skip", () {
    testWidgets("Should skip to Person page", (WidgetTester tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          routes: [
            AppPageRoute(
              path: "family",
              name: "family",
              builder: (_, __) => const FamilyPage(""),
              skip: (_) => SkipOption.goToChild,
              routes: [
                AppPageRoute(
                  path: "person",
                  name: "person",
                  builder: (_, __) => const FamilyPeronsPage("", ""),
                ),
              ],
            ),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);
      router.go("/family");
      await tester.pumpAndSettle();
      expect(router.currentLocation!.path, "/family/person");
      expect(find.byType(FamilyPeronsPage), findsOneWidget);
    });

    testWidgets("Should skip to Start page", (WidgetTester tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          routes: [
            AppPageRoute(
              path: "family",
              name: "family",
              builder: (_, __) => const FamilyPage(""),
              skip: (_) => SkipOption.goToParent,
              routes: [
                AppPageRoute(
                  path: "person",
                  name: "person",
                  builder: (_, __) => const FamilyPeronsPage("", ""),
                ),
              ],
            ),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);
      router.go("/family");
      await tester.pump();
      expect(router.currentLocation!.path, "/");
      expect(find.byType(StartScreen), findsOneWidget);
    });

    testWidgets("Should skip to last page", (WidgetTester tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          skip: (_) => SkipOption.goToChild,
          routes: [
            AppPageRoute(
              path: "family",
              name: "family",
              builder: (_, __) => const FamilyPage(""),
              skip: (_) => SkipOption.goToChild,
              routes: [
                AppPageRoute(
                  path: "person",
                  name: "person",
                  builder: (_, __) => const FamilyPeronsPage("", ""),
                ),
              ],
            ),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);
      router.go("/");
      await tester.pump();
      expect(router.currentLocation!.path, "/family/person");
      expect(find.byType(FamilyPeronsPage), findsOneWidget);
    });

    testWidgets("Should throw error when skip limit has been reached",
        (WidgetTester tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          skip: (_) => SkipOption.goToChild,
          routes: [
            AppPageRoute(
              path: "family",
              name: "family",
              builder: (_, __) => const FamilyPage(""),
              skip: (_) => SkipOption.goToParent,
            ),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);
      router.go("/");
      await tester.pump();
      expect(router.currentLocation!.path, "/");
      expect(find.byType(ErrorScreen), findsOneWidget);
    });

    testWidgets("Skip state", (WidgetTester tester) async {
      const String loc = "/start";
      final routes = [
        AppPageRoute(
          path: "/start",
          name: "start",
          skip: (AppRouterPageState state) {
            expect(state.name, "start");
            expect(state.fullpath, "/start");
            return null;
          },
          builder: startScreen,
        ),
      ];

      final router = await _createRouter(routes, tester, initialLocation: loc);

      final foundRoutes = router.routerDelegate.routerPaths.routes;
      expect(foundRoutes, hasLength(1));
      expect(find.byType(StartScreen), findsOneWidget);
    });

    testWidgets("Extra not null in skip", (WidgetTester tester) async {
      bool isCallSkip = false;

      final List<AppPageRoute> routes = <AppPageRoute>[
        AppPageRoute(
          name: "start",
          path: "/",
          builder: startScreen,
          routes: [
            AppPageRoute(
              name: "test",
              path: "test",
              builder: testScreen,
              skip: (AppRouterPageState state) {
                isCallSkip = true;
                expect(state.extra, isNotNull);
                return null;
              },
            ),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);

      router.go("/test", extra: 1);
      await tester.pump();

      expect(isCallSkip, true);
    });
  });

  group("initial location", () {
    testWidgets("initial location", (WidgetTester tester) async {
      final List<AppPageRoute> routes = <AppPageRoute>[
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          routes: [
            AppPageRoute(path: "test", name: "test", builder: testScreen),
          ],
        ),
      ];

      final router = await _createRouter(
        routes,
        tester,
        initialLocation: "/test",
      );
      expect(router.currentLocation!.path, "/test");
    });

    testWidgets("initial named location", (WidgetTester tester) async {
      final List<AppPageRoute> routes = <AppPageRoute>[
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          routes: [
            AppPageRoute(path: "test", name: "test", builder: testScreen),
          ],
        ),
      ];

      final router = await _createRouter(
        routes,
        tester,
        initialNamedLocation: "test",
      );
      expect(router.currentLocation!.path, "/test");
    });

    testWidgets("initial location with skip", (WidgetTester tester) async {
      final List<AppPageRoute> routes = <AppPageRoute>[
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          skip: (_) => SkipOption.goToChild,
          routes: [
            AppPageRoute(path: "test", name: "test", builder: testScreen),
          ],
        ),
      ];

      final router = await _createRouter(
        routes,
        tester,
        initialLocation: "/",
      );
      expect(router.currentLocation!.path, "/test");
    });

    testWidgets(
        "does not take precedence over platformDispatcher.defaultRouteName",
        (WidgetTester tester) async {
      final instance = TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;
      instance.window.defaultRouteNameTestValue = "/test";
      tester.binding.window.defaultRouteNameTestValue = "/test";

      final List<AppPageRoute> routes = <AppPageRoute>[
        AppPageRoute(
          path: "/",
          name: "start",
          builder: startScreen,
          routes: [
            AppPageRoute(path: "test", name: "test", builder: testScreen),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);
      expect(router.routeInformationProvider?.value.location, "/test");
      instance.window.defaultRouteNameTestValue = "/";
    }, skip: true);
  });

  group("Extensions", () {
    final key = GlobalKey<TestStatefullWidgetState>();
    final routes = [
      AppPageRoute(
        path: "/",
        name: "start",
        builder: (_, __) => TestStatefullWidget(key: key),
      ),
      AppPageRoute(path: "/test", name: "test", builder: testScreen),
    ];

    const String name = "test";
    const String location = "/test";
    const String extra = "Extre object";

    testWidgets("Call go on closest AppRouter", (
      WidgetTester tester,
    ) async {
      final router = AppRouterSpy(routes: routes);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: router.backButtonDispatcher,
          routeInformationProvider: router.routeInformationProvider,
          title: "AppRouter Example",
        ),
      );
      await tester.pumpAndSettle();
      key.currentContext!.go(
        location,
        extra: extra,
        backToCaller: true,
      );
      expect(router.routerLocation, location);
      expect(router.extra, extra);
      expect(router.backToCaller, true);
    });

    testWidgets("Call goNamed on closest AppRouter", (
      WidgetTester tester,
    ) async {
      final router = AppRouterSpy(routes: routes);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: router.backButtonDispatcher,
          routeInformationProvider: router.routeInformationProvider,
          title: "AppRouter Example",
        ),
      );
      await tester.pumpAndSettle();
      key.currentContext!.goNamed(
        name,
        extra: extra,
        backToCaller: true,
      );
      expect(router.routerName, name);
      expect(router.extra, extra);
      expect(router.backToCaller, true);
    });

    testWidgets("call push on closest AppPageRouter",
        (WidgetTester tester) async {
      final router = AppRouterSpy(routes: routes);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: router.backButtonDispatcher,
          routeInformationProvider: router.routeInformationProvider,
          title: "AppRouter Example",
        ),
      );
      await tester.pumpAndSettle();
      key.currentContext!.push(
        location,
        extra: extra,
      );
      expect(router.routerLocation, location);
      expect(router.extra, extra);
    });

    testWidgets("Call pushNamed on closest AppRouter",
        (WidgetTester tester) async {
      final router = AppRouterSpy(routes: routes);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: router.backButtonDispatcher,
          routeInformationProvider: router.routeInformationProvider,
          title: "AppRouter Example",
        ),
      );
      await tester.pumpAndSettle();
      key.currentContext!.pushNamed(
        name,
        extra: extra,
      );
      expect(router.routerName, name);
      expect(router.extra, extra);
    });

    testWidgets("Call pop on closest AppRouter", (WidgetTester tester) async {
      final router = AppRouterSpy(routes: routes);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: router.backButtonDispatcher,
          routeInformationProvider: router.routeInformationProvider,
          title: "AppRouter Example",
        ),
      );
      await tester.pumpAndSettle();
      key.currentContext!.pop();
      expect(router.popped, true);
    });
  });

  group("ShellRoute", () {
    testWidgets("defaultRoute", (WidgetTester tester) async {
      final routes = [
        ShellRoute(
          builder: (_, __, Widget child) {
            return Scaffold(body: child);
          },
          routes: [
            AppPageRoute(
              path: "/a",
              name: "a",
              builder: (_, __) {
                return const Scaffold(body: Text("Screen A"));
              },
            ),
            AppPageRoute(
              path: "/b",
              name: "b",
              builder: (_, __) {
                return const Scaffold(body: Text("Screen B"));
              },
            ),
          ],
        ),
      ];

      await _createRouter(routes, tester, initialLocation: "/b");
      expect(find.text("Screen B"), findsOneWidget);
    });

    testWidgets(
        "Pops from the correct Navigator when the Android back button is pressed",
        (
      WidgetTester tester,
    ) async {
      final routes = [
        ShellRoute(
          builder: (_, __, Widget child) {
            return Scaffold(
              body: Column(
                children: <Widget>[
                  const Text("Screen A"),
                  Expanded(child: child),
                ],
              ),
            );
          },
          routes: [
            AppPageRoute(
              path: "/b",
              name: "b",
              builder: (_, __) {
                return const Scaffold(body: Text("Screen B"));
              },
              routes: [
                AppPageRoute(
                  path: "c",
                  name: "c",
                  builder: (_, __) {
                    return const Scaffold(body: Text("Screen C"));
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      await _createRouter(routes, tester, initialLocation: "/b/c");
      expect(find.text("Screen A"), findsOneWidget);
      expect(find.text("Screen B"), findsNothing);
      expect(find.text("Screen C"), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      expect(find.text("Screen A"), findsOneWidget);
      expect(find.text("Screen B"), findsOneWidget);
      expect(find.text("Screen C"), findsNothing);
    });

    testWidgets(
        "Pops from the correct navigator when a sub-route is placed on the root Navigator",
        (
      WidgetTester tester,
    ) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>();
      final shellNavigatorKey = GlobalKey<NavigatorState>();

      final routes = [
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (_, __, Widget child) {
            return Scaffold(
              body: Column(
                children: <Widget>[
                  const Text("Screen A"),
                  Expanded(child: child),
                ],
              ),
            );
          },
          routes: [
            AppPageRoute(
              path: "/b",
              name: "b",
              builder: (_, __) {
                return const Scaffold(body: Text("Screen B"));
              },
              routes: [
                AppPageRoute(
                  path: "c",
                  name: "c",
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (_, __) {
                    return const Scaffold(body: Text("Screen C"));
                  },
                ),
              ],
            ),
          ],
        ),
      ];

      await _createRouter(
        routes,
        tester,
        initialLocation: "/b/c",
        navigatorKey: rootNavigatorKey,
      );
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen B"), findsNothing);
      expect(find.text("Screen C"), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      expect(find.text("Screen A"), findsOneWidget);
      expect(find.text("Screen B"), findsOneWidget);
      expect(find.text("Screen C"), findsNothing);
    });

    testWidgets(
        "Navigates to correct nested navigation tree in StatefulShellRoute and maintains state",
        (WidgetTester tester) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>();
      final sectionANavigatorKey = GlobalKey<NavigatorState>();
      final sectionBNavigatorKey = GlobalKey<NavigatorState>();
      final statefulWidgetKey = GlobalKey<TestStatefullWidgetState>();

      final routes = [
        StatefulShellRoute.rootRoutes(
          builder: (_, __, Widget child) => child,
          routes: [
            AppPageRoute(
              parentNavigatorKey: sectionANavigatorKey,
              path: "/a",
              name: "a",
              builder: (_, __) => const Text("Screen A"),
              routes: [
                AppPageRoute(
                  path: "detailA",
                  name: "detailA",
                  builder: (_, __) => Column(children: <Widget>[
                    const Text("Screen A Detail"),
                    TestStatefullWidget(key: statefulWidgetKey),
                  ]),
                ),
              ],
            ),
            AppPageRoute(
              parentNavigatorKey: sectionBNavigatorKey,
              path: "/b",
              name: "b",
              builder: (_, __) => const Text("Screen B"),
            ),
          ],
        ),
      ];

      final router = await _createRouter(
        routes,
        tester,
        initialLocation: "/a/detailA",
        navigatorKey: rootNavigatorKey,
      );

      statefulWidgetKey.currentState?.increment();
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen A Detail"), findsOneWidget);
      expect(find.text("Screen B"), findsNothing);

      router.go("/b");
      await tester.pumpAndSettle();
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen A Detail"), findsNothing);
      expect(find.text("Screen B"), findsOneWidget);

      router.go("/a/detailA");
      await tester.pumpAndSettle();
      expect(statefulWidgetKey.currentState?.counter, equals(1));

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text("Screen A"), findsOneWidget);
      expect(find.text("Screen A Detail"), findsNothing);
      router.go("/a/detailA");
      await tester.pumpAndSettle();
      expect(statefulWidgetKey.currentState?.counter, equals(0));
    });

    testWidgets(
        "Pops from the correct Navigator in a StatefulShellRoute when the Android back button is pressed",
        (
      WidgetTester tester,
    ) async {
      final rootNavigatorKey = GlobalKey<NavigatorState>();
      final sectionANavigatorKey = GlobalKey<NavigatorState>();
      final sectionBNavigatorKey = GlobalKey<NavigatorState>();

      final routes = [
        StatefulShellRoute.rootRoutes(
          builder: (_, __, Widget child) => child,
          routes: [
            AppPageRoute(
              parentNavigatorKey: sectionANavigatorKey,
              path: "/a",
              name: "a",
              builder: (_, __) => const Text("Screen A"),
              routes: [
                AppPageRoute(
                  path: "detailA",
                  name: "detailA",
                  builder: (_, __) => const Text("Screen A Detail"),
                ),
              ],
            ),
            AppPageRoute(
              parentNavigatorKey: sectionBNavigatorKey,
              path: "/b",
              name: "b",
              builder: (_, __) => const Text("Screen B"),
              routes: [
                AppPageRoute(
                  path: "detailB",
                  name: "detailB",
                  builder: (_, __) => const Text("Screen B Detail"),
                ),
              ],
            ),
          ],
        ),
      ];

      final router = await _createRouter(
        routes,
        tester,
        initialLocation: "/a/detailA",
        navigatorKey: rootNavigatorKey,
      );
      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen A Detail"), findsOneWidget);
      expect(find.text("Screen B"), findsNothing);
      expect(find.text("Screen B Detail"), findsNothing);

      router.go("/b/detailB");
      await tester.pumpAndSettle();

      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen A Detail"), findsNothing);
      expect(find.text("Screen B"), findsNothing);
      expect(find.text("Screen B Detail"), findsOneWidget);

      await simulateAndroidBackButton(tester);
      await tester.pumpAndSettle();

      expect(find.text("Screen A"), findsNothing);
      expect(find.text("Screen A Detail"), findsNothing);
      expect(find.text("Screen B"), findsOneWidget);
      expect(find.text("Screen B Detail"), findsNothing);
    });
  });

  group("Pop navigation", () {
    testWidgets("pop triggers pop on routerDelegate",
        (WidgetTester tester) async {
      final router = await _createRouter(
        [
          AppPageRoute(path: "/", name: "start", builder: startScreen),
          AppPageRoute(path: "/test", name: "test", builder: testScreen),
        ],
        tester,
      );
      router.push("/test");
      await tester.pumpAndSettle();
      router.routerDelegate.addListener(expectAsync0(() {}));
      router.pop();
      await tester.pump();
    });

    group("canPop", () {
      testWidgets(
        "It should return false if Navigator.canPop() returns false.",
        (WidgetTester tester) async {
          final navigatorKey = GlobalKey<NavigatorState>();
          final routes = [
            AppPageRoute(
              path: "/",
              name: "start",
              builder: (BuildContext context, _) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      navigatorKey.currentState!.push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const Scaffold(
                              body: Text("Pushed route"),
                            );
                          },
                        ),
                      );
                    },
                    child: const Text("Push"),
                  ),
                );
              },
            ),
            AppPageRoute(path: "/test", name: "test", builder: testScreen),
          ];
          final router = await _createRouter(
            routes,
            tester,
            navigatorKey: navigatorKey,
          );
          expect(router.canPop(), false);

          await tester.tap(find.text("Push"));
          await tester.pumpAndSettle();

          expect(
            find.text("Pushed route", skipOffstage: false),
            findsOneWidget,
          );
          expect(router.canPop(), true);
        },
      );

      testWidgets(
        "It checks if ShellRoute navigators can pop",
        (WidgetTester tester) async {
          final shellNavigatorKey = GlobalKey<NavigatorState>();
          final routes = [
            ShellRoute(
              navigatorKey: shellNavigatorKey,
              builder: (_, __, Widget child) {
                return Scaffold(
                  appBar: AppBar(title: const Text("Shell")),
                  body: child,
                );
              },
              routes: <AppPageRoute>[
                AppPageRoute(
                  path: "/a",
                  name: "a",
                  builder: (BuildContext context, _) {
                    return Scaffold(
                      body: TextButton(
                        onPressed: () async {
                          shellNavigatorKey.currentState!.push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return const Scaffold(
                                  body: Text("Pushed route"),
                                );
                              },
                            ),
                          );
                        },
                        child: const Text("Push"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ];

          final router = await _createRouter(
            routes,
            tester,
            initialLocation: "/a",
          );
          expect(router.canPop(), false);
          expect(find.text("Push"), findsOneWidget);

          await tester.tap(find.text("Push"));
          await tester.pumpAndSettle();

          expect(
              find.text("Pushed route", skipOffstage: false), findsOneWidget);
          expect(router.canPop(), true);
        },
      );

      testWidgets(
        "It checks if ShellRoute navigators can pop",
        (WidgetTester tester) async {
          final shellNavigatorKey = GlobalKey<NavigatorState>();
          final routes = [
            ShellRoute(
              navigatorKey: shellNavigatorKey,
              builder: (_, __, Widget child) {
                return Scaffold(
                  appBar: AppBar(title: const Text("Shell")),
                  body: child,
                );
              },
              routes: <AppPageRoute>[
                AppPageRoute(
                  path: "/a",
                  name: "a",
                  builder: (BuildContext context, _) {
                    return Scaffold(
                      body: TextButton(
                        onPressed: () async {
                          shellNavigatorKey.currentState!.push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const Scaffold(
                                  body: Text("Pushed route"),
                                );
                              },
                            ),
                          );
                        },
                        child: const Text("Push"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ];

          final router = await _createRouter(
            routes,
            tester,
            initialLocation: "/a",
          );

          expect(router.canPop(), false);
          expect(find.text("Push"), findsOneWidget);

          await tester.tap(find.text("Push"));
          await tester.pumpAndSettle();

          expect(
              find.text("Pushed route", skipOffstage: false), findsOneWidget);
          expect(router.canPop(), true);
        },
      );
    });

    group("pop", () {
      testWidgets(
        "Should pop from the correct navigator when parentNavigatorKey is set",
        (WidgetTester tester) async {
          final root = GlobalKey<NavigatorState>();
          final shell = GlobalKey<NavigatorState>();

          final routes = [
            AppPageRoute(
              path: "/",
              name: "start",
              builder: (_, __) {
                return const Scaffold(body: Text("Home"));
              },
              routes: [
                ShellRoute(
                  navigatorKey: shell,
                  builder: (_, __, Widget child) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          children: [
                            const Text("Shell"),
                            Expanded(child: child),
                          ],
                        ),
                      ),
                    );
                  },
                  routes: [
                    AppPageRoute(
                      path: "a",
                      name: "a",
                      builder: (_, __) => const Text("A Screen"),
                      routes: [
                        AppPageRoute(
                          parentNavigatorKey: root,
                          path: "b",
                          name: "b",
                          builder: (_, __) => const Text("B Screen"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ];
          final router = await _createRouter(
            routes,
            tester,
            initialLocation: "/a/b",
            navigatorKey: root,
          );

          expect(router.canPop(), isTrue);
          expect(find.text("B Screen"), findsOneWidget);
          expect(find.text("A Screen"), findsNothing);
          expect(find.text("Shell"), findsNothing);
          expect(find.text("Home"), findsNothing);
          router.pop();
          await tester.pumpAndSettle();
          expect(find.text("A Screen"), findsOneWidget);
          expect(find.text("Shell"), findsOneWidget);
          expect(router.canPop(), isTrue);
          router.pop();
          await tester.pumpAndSettle();
          expect(find.text("Home"), findsOneWidget);
          expect(find.text("Shell"), findsNothing);
        },
      );

      testWidgets(
        "Should pop to callerPage for the first time, then should pop to parent",
        (WidgetTester tester) async {
          final routes = [
            StatefulShellRoute(
              branches: [
                ShellRouteBranch(
                  rootRoute: AppPageRoute(
                    path: "/a",
                    name: "a",
                    builder: (ctx, __) {
                      return Column(
                        children: [
                          const Text("A Screen"),
                          Builder(builder: (newCtx) {
                            return TextButton(
                              onPressed: () {
                                StatefulShellRoute.of(newCtx).goToBranch(1);
                              },
                              child: const Text("Change tab"),
                            );
                          })
                        ],
                      );
                    },
                  ),
                ),
                ShellRouteBranch(
                  rootRoute: AppPageRoute(
                    path: "/b",
                    name: "b",
                    builder: (_, __) => const Text("B Screen"),
                    routes: [
                      AppPageRoute(
                        path: "child",
                        name: "childB",
                        builder: (_, __) => const Text("A child Screen"),
                      ),
                    ],
                  ),
                ),
              ],
              builder: (_, __, child) => child,
            ),
          ];
          final router = await _createRouter(
            routes,
            tester,
            initialLocation: "/a",
          );

          router.go("/b/child", backToCaller: true);
          await tester.pumpAndSettle();
          expect(find.text("B Screen"), findsNothing);
          expect(find.text("A Screen"), findsNothing);
          expect(find.text("A child Screen"), findsOneWidget);

          router.pop();
          await tester.pumpAndSettle();
          expect(find.text("B Screen"), findsNothing);
          expect(find.text("A Screen"), findsOneWidget);
          expect(find.text("A child Screen"), findsNothing);

          await tester.tap(find.text("Change tab"));
          await tester.pumpAndSettle();
          expect(find.text("B Screen"), findsNothing);
          expect(find.text("A Screen"), findsNothing);
          expect(find.text("A child Screen"), findsOneWidget);

          router.pop();
          await tester.pumpAndSettle();
          expect(find.text("B Screen"), findsOneWidget);
          expect(find.text("A Screen"), findsNothing);
          expect(find.text("A child Screen"), findsNothing);
        },
      );
    });
  });

  group("Bloc provider", () {
    testWidgets("Should read bloc form context in builder", (tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (ctx, __) {
            return BlocBuilder<SampleCubit, SampleCubitState>(builder: (_, __) {
              return const Scaffold(body: Text("Start"));
            });
          },
          providersBuilder: (_) => [SampleCubit()],
        ),
      ];
      await _createRouter(
        routes,
        tester,
      );
      expect(find.text("Start"), findsOneWidget);
    });

    testWidgets("Should update bloc state", (tester) async {
      final sampleCubit = SampleCubit();
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (ctx, __) {
            return BlocBuilder<SampleCubit, SampleCubitState>(
                builder: (_, state) {
              return Scaffold(body: Text("State: ${state.message}"));
            });
          },
          providersBuilder: (_) => [sampleCubit],
        ),
      ];
      await _createRouter(
        routes,
        tester,
      );
      expect(find.text("State: "), findsOneWidget);
      sampleCubit.setMessage("New state");
      await tester.pumpAndSettle();
      expect(find.text("State: New state"), findsOneWidget);
    });

    testWidgets(
        "Should read bloc form context in builder with StatefulShellRoute",
        (tester) async {
      final routes = [
        StatefulShellRoute(
          builder: (_, __, Widget child) => child,
          branches: [
            ShellRouteBranch(
              rootRoute: AppPageRoute(
                path: "/",
                name: "start",
                builder: (ctx, __) {
                  return BlocBuilder<SampleCubit, SampleCubitState>(
                      builder: (_, __) {
                    return const Scaffold(body: Text("Start"));
                  });
                },
              ),
              providersBuilder: () => [SampleCubit()],
            ),
          ],
        ),
      ];
      await _createRouter(
        routes,
        tester,
      );
      expect(find.text("Start"), findsOneWidget);
    });

    testWidgets("Should update bloc state with StatefulShellRoute",
        (tester) async {
      final sampleCubit = SampleCubit();
      final routes = [
        StatefulShellRoute(
          builder: (_, __, Widget child) => child,
          branches: [
            ShellRouteBranch(
              rootRoute: AppPageRoute(
                path: "/",
                name: "start",
                builder: (ctx, __) {
                  return BlocBuilder<SampleCubit, SampleCubitState>(
                      builder: (_, state) {
                    return Scaffold(body: Text("State: ${state.message}"));
                  });
                },
              ),
              providersBuilder: () => [sampleCubit],
            ),
          ],
        ),
      ];

      await _createRouter(
        routes,
        tester,
      );
      expect(find.text("State: "), findsOneWidget);
      sampleCubit.setMessage("New state");
      await tester.pumpAndSettle();
      expect(find.text("State: New state"), findsOneWidget);
    });

    testWidgets("Should read bloc in sub-route", (tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (ctx, __) {
            return BlocBuilder<SampleCubit, SampleCubitState>(builder: (_, __) {
              return const Scaffold(body: Text("Start"));
            });
          },
          providersBuilder: (_) => [SampleCubit(message: "parent route")],
          routes: [
            AppPageRoute(
              path: "child",
              name: "child",
              builder: (ctx, __) {
                return BlocBuilder<SampleCubit, SampleCubitState>(
                    builder: (_, state) {
                  return Scaffold(body: Text("Child: ${state.message}"));
                });
              },
            ),
          ],
        ),
      ];
      final router = await _createRouter(routes, tester);
      expect(find.text("Start"), findsOneWidget);
      router.go("/child");
      await tester.pumpAndSettle();
      expect(find.text("Child: parent route"), findsOneWidget);
    });

    testWidgets("Should update bloc in sub-route", (tester) async {
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (_, __) {
            return BlocBuilder<SampleCubit, SampleCubitState>(
                builder: (_, state) {
              return Scaffold(body: Text("Parent: ${state.message}"));
            });
          },
          providersBuilder: (_) => [SampleCubit(message: "Parent route")],
          routes: [
            AppPageRoute(
              path: "child",
              name: "child",
              builder: (_, __) {
                return BlocBuilder<SampleCubit, SampleCubitState>(
                    builder: (ctx, state) {
                  ctx.read<SampleCubit>().setMessage("Child route");
                  return Scaffold(body: Text("Child: ${state.message}"));
                });
              },
            ),
          ],
        ),
      ];
      final router = await _createRouter(routes, tester);
      expect(find.text("Parent: Parent route"), findsOneWidget);
      router.go("/child");
      await tester.pumpAndSettle();
      expect(find.text("Child: Parent route"), findsOneWidget);
      router.go("/");
      await tester.pumpAndSettle();
      expect(find.text("Parent: Child route"), findsOneWidget);
    });

    testWidgets("Should close sub-route cubit", (tester) async {
      final mockCubit = MockSampleCubit();
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (_, __) {
            return const Scaffold(body: Text("Parent"));
          },
          routes: [
            AppPageRoute(
              path: "child",
              name: "child",
              builder: (_, __) {
                return const Scaffold(body: Text("Child"));
              },
              providersBuilder: (_) => [mockCubit],
            ),
          ],
        ),
      ];
      final router = await _createRouter(routes, tester);

      router.go("/child");
      await tester.pumpAndSettle();
      router.go("/");
      await tester.pumpAndSettle();
      verify(() => mockCubit.close()).called(1);
    });

    testWidgets("Should close only sub-route cubit with StatefulShellRoute",
        (tester) async {
      var sampleCubitClosed = false;
      var sampleCubitClosed2 = false;
      var sampleCubitClosed3 = false;
      final sampleCubit = SampleCubit(
        onClose: () => sampleCubitClosed = true,
      );
      final sampleCubit2 = SampleCubit2(
        onClose: () => sampleCubitClosed2 = true,
      );
      final sampleCubit3 = SampleCubit3(
        onClose: () => sampleCubitClosed3 = true,
      );

      final routes = [
        StatefulShellRoute(
          builder: (_, __, Widget child) => child,
          branches: [
            ShellRouteBranch(
              rootRoute: AppPageRoute(
                path: "/",
                name: "start",
                builder: (ctx, __) {
                  return BlocBuilder<SampleCubit, SampleCubitState>(
                      builder: (_, __) {
                    return const Scaffold(body: Text("Start"));
                  });
                },
              ),
              providersBuilder: () => [sampleCubit],
            ),
            ShellRouteBranch(
              rootRoute: AppPageRoute(
                path: "/a",
                name: "a",
                builder: (ctx, __) {
                  return BlocBuilder<SampleCubit2, SampleCubitState>(
                      builder: (_, __) {
                    return const Scaffold(body: Text("A Page"));
                  });
                },
                routes: [
                  AppPageRoute(
                    path: "child",
                    name: "aChild",
                    builder: (ctx, __) {
                      return BlocBuilder<SampleCubit3, SampleCubitState>(
                          builder: (_, __) {
                        return const Scaffold(body: Text("Start"));
                      });
                    },
                    providersBuilder: (_) => [sampleCubit3],
                  ),
                ],
              ),
              providersBuilder: () => [sampleCubit2],
            ),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);

      router.go("/a");
      await tester.pumpAndSettle();
      router.go("/a/child");
      await tester.pumpAndSettle();
      router.go("/");
      await tester.pumpAndSettle();
      expect(sampleCubitClosed3, false);
      router.go("/a");
      await tester.pumpAndSettle();
      expect(sampleCubitClosed, false);
      expect(sampleCubitClosed2, false);
      expect(sampleCubitClosed3, true);
    });

    testWidgets(
        "Should close all cubits when go to another root route of StatefulShellRoute",
        (tester) async {
      var sampleCubitClosed = false;
      var sampleCubitClosed2 = false;
      var sampleCubitClosed3 = false;
      final sampleCubit = SampleCubit(
        onClose: () => sampleCubitClosed = true,
      );
      final sampleCubit2 = SampleCubit2(
        onClose: () => sampleCubitClosed2 = true,
      );
      final sampleCubit3 = SampleCubit3(
        onClose: () => sampleCubitClosed3 = true,
      );

      final routes = [
        AppPageRoute(path: "/test", name: "test", builder: testScreen),
        StatefulShellRoute(
          builder: (_, __, Widget child) => child,
          branches: [
            ShellRouteBranch(
              rootRoute: AppPageRoute(
                path: "/",
                name: "start",
                builder: (ctx, __) {
                  return BlocBuilder<SampleCubit, SampleCubitState>(
                      builder: (_, __) {
                    return const Scaffold(body: Text("Start"));
                  });
                },
              ),
              providersBuilder: () => [sampleCubit],
            ),
            ShellRouteBranch(
              rootRoute: AppPageRoute(
                path: "/a",
                name: "a",
                builder: (ctx, __) {
                  return BlocBuilder<SampleCubit2, SampleCubitState>(
                      builder: (_, __) {
                    return const Scaffold(body: Text("A Page"));
                  });
                },
                routes: [
                  AppPageRoute(
                    path: "child",
                    name: "aChild",
                    builder: (ctx, __) {
                      return BlocBuilder<SampleCubit3, SampleCubitState>(
                          builder: (_, __) {
                        return const Scaffold(body: Text("Start"));
                      });
                    },
                    providersBuilder: (_) => [sampleCubit3],
                  ),
                ],
              ),
              providersBuilder: () => [sampleCubit2],
            ),
          ],
        ),
      ];

      final router = await _createRouter(routes, tester);

      router.go("/a");
      await tester.pumpAndSettle();
      router.go("/a/child");
      await tester.pumpAndSettle();
      router.go("/test");
      await tester.pumpAndSettle();
      await tester.pump();
      expect(sampleCubitClosed, true);
      expect(sampleCubitClosed2, true);
      expect(sampleCubitClosed3, true);
    });

    testWidgets("Should get SampleCubit by cubitGetter", (tester) async {
      final sampleCubit = SampleCubit(message: "parent route");
      final routes = [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (ctx, __) {
            return BlocBuilder<SampleCubit, SampleCubitState>(builder: (_, __) {
              return const Scaffold(body: Text("Start"));
            });
          },
          providersBuilder: (_) => [sampleCubit],
          routes: [
            AppPageRoute(
              path: "child",
              name: "child",
              builder: (ctx, __) {
                return BlocBuilder<SampleCubitWithDependency, SampleCubitState>(
                    builder: (_, state) {
                  return Scaffold(body: Text("Child: ${state.message}"));
                });
              },
              providersBuilder: (cubitGetter) {
                final cubit = cubitGetter<SampleCubit>();
                expect(cubit, sampleCubit);
                return [
                  SampleCubitWithDependency(
                    sampleCubit: cubit,
                    message: "Dependency with ${cubit!.state.message}",
                  ),
                ];
              },
            ),
          ],
        ),
      ];
      final router = await _createRouter(routes, tester);
      expect(find.text("Start"), findsOneWidget);
      router.go("/child");
      await tester.pumpAndSettle();
      expect(find.text("Child: Dependency with parent route"), findsOneWidget);
    });
  });
}
