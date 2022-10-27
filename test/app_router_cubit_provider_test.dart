import 'package:app_router/app_router.dart';
import 'package:app_router/route_finder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleFoundRoute1 = _MockFoundRoute("name1");
  final sampleFoundRoute2 = _MockFoundRoute("name2");
  final sampleFoundRoute3 = _MockFoundRoute("name3");
  final sampleFoundRoute4 = _MockFoundRoute("name4");
  final sampleFoundRoute5 = _MockFoundRoute("name5");
  final sampleFoundRoute6 = _MockFoundRoute("name6");

  group("commonRoutes", () {
    test("empty routes", () {
      final result = AppRouterCubitProvider().commonRoutes(
        previousRoute: RouterPaths.empty(),
        newRouterPaths: RouterPaths.empty(),
      );

      expect(result, []);
    });

    test("first not empty, second empty", () {
      final result = AppRouterCubitProvider().commonRoutes(
        previousRoute: RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
        newRouterPaths: RouterPaths.empty(),
      );

      expect(result, []);
    });
    test("first  empty, second not empty", () {
      final result = AppRouterCubitProvider().commonRoutes(
        previousRoute: RouterPaths.empty(),
        newRouterPaths: RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
      );

      expect(result, []);
    });

    test("one common", () {
      final result = AppRouterCubitProvider().commonRoutes(
        previousRoute: RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
        newRouterPaths: RouterPaths([sampleFoundRoute1]),
      );

      expect(result, [sampleFoundRoute1.route]);
    });

    test("one common", () {
      final result = AppRouterCubitProvider().commonRoutes(
        previousRoute: RouterPaths([sampleFoundRoute1]),
        newRouterPaths: RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
      );

      expect(result, [sampleFoundRoute1.route]);
    });

    test("two common", () {
      final result = AppRouterCubitProvider().commonRoutes(
        previousRoute: RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
        newRouterPaths: RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
      );

      expect(result, [sampleFoundRoute1.route, sampleFoundRoute2.route]);
    });
    test("mixed1", () {
      final result = AppRouterCubitProvider().commonRoutes(
        previousRoute: RouterPaths([
          sampleFoundRoute1,
          sampleFoundRoute2,
          sampleFoundRoute3,
        ]),
        newRouterPaths: RouterPaths([sampleFoundRoute1, sampleFoundRoute3]),
      );

      expect(result, [sampleFoundRoute1.route, sampleFoundRoute3.route]);
    });
  });

  group("getAllRoutesToRemove", () {
    test("Previous routes is empty", () {
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [],
        newRouterPaths: RouterPaths([sampleFoundRoute1]),
      );

      expect(result, []);
    });
    test("Last previous route is empty", () {
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [const RouterPaths([])],
        newRouterPaths: RouterPaths([sampleFoundRoute1]),
      );

      expect(result, []);
    });
    test("New location is null", () {
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [
          RouterPaths([
            sampleFoundRoute1,
            sampleFoundRoute2,
          ])
        ],
        newRouterPaths: const RouterPaths([]),
      );

      expect(result, []);
    });

    test("remove old RouterPath with the same root route - test 1", () {
      final routerPaths1 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute2,
      ]);
      final routerPaths2 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute2,
        sampleFoundRoute3,
      ]);
      final routerPaths3 = RouterPaths([
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [
          routerPaths1,
          routerPaths2,
          routerPaths3,
        ],
        newRouterPaths: RouterPaths([
          sampleFoundRoute1,
          sampleFoundRoute2,
          sampleFoundRoute3,
          sampleFoundRoute4
        ]),
      );

      expect(result, [routerPaths1, routerPaths2]);
    });

    test("remove old RouterPath with the same root route - test 2", () {
      final routerPaths1 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute2,
      ]);
      final routerPaths2 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute2,
        sampleFoundRoute3,
      ]);
      final routerPaths3 = RouterPaths([
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final routerPaths4 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [
          routerPaths1,
          routerPaths2,
          routerPaths3,
          routerPaths4,
        ],
        newRouterPaths: RouterPaths([
          sampleFoundRoute1,
          sampleFoundRoute2,
          sampleFoundRoute3,
          sampleFoundRoute4
        ]),
      );

      expect(result, [routerPaths1, routerPaths2, routerPaths4]);
    });
    test("remove old RouterPath with the same root route - test 3", () {
      final routerPaths1 = RouterPaths([
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final routerPaths2 = RouterPaths([
        sampleFoundRoute3,
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [
          routerPaths1,
          routerPaths2,
        ],
        newRouterPaths: RouterPaths([
          sampleFoundRoute1,
          sampleFoundRoute2,
          sampleFoundRoute3,
          sampleFoundRoute4
        ]),
      );

      expect(result, []);
    });
    test("remove old RouterPath with the same root route - test 4", () {
      final routerPaths1 = RouterPaths([
        sampleFoundRoute3,
        sampleFoundRoute5,
      ]);
      final routerPaths2 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [
          routerPaths1,
          routerPaths2,
        ],
        newRouterPaths: routerPaths2,
      );

      expect(result, [routerPaths2]);
    });
    test("remove old RouterPath with the same root route - test 5", () {
      final routerPaths1 = RouterPaths([
        sampleFoundRoute3,
        sampleFoundRoute5,
      ]);
      final routerPaths2 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final routerPaths3 = RouterPaths([
        sampleFoundRoute1,
        sampleFoundRoute2,
        sampleFoundRoute3,
        sampleFoundRoute4,
        sampleFoundRoute5,
      ]);
      final result = AppRouterCubitProvider().getAllRouterPathsToRemove(
        previousRoutes: [
          routerPaths1,
          routerPaths2,
          routerPaths3,
        ],
        newRouterPaths: routerPaths2,
      );

      expect(result, [routerPaths2, routerPaths3]);
    });
  });

  group("getAllRoutesToRemove", () {
    test("routerPathsToRemove is empty", () {
      final result = AppRouterCubitProvider().getAllRoutesToRemove(
        routerPathsToRemove: [],
        newRouterPaths: RouterPaths([sampleFoundRoute1]),
      );

      expect(result, []);
    });
    test("routerPathsToRemove is not empty", () {
      final result = AppRouterCubitProvider().getAllRoutesToRemove(
        routerPathsToRemove: [
          RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
          RouterPaths([sampleFoundRoute1, sampleFoundRoute3]),
          RouterPaths([sampleFoundRoute3, sampleFoundRoute4]),
          RouterPaths([sampleFoundRoute5, sampleFoundRoute6]),
        ],
        newRouterPaths: RouterPaths([
          sampleFoundRoute1,
          sampleFoundRoute2,
          sampleFoundRoute3,
        ]),
      );

      expect(result, [
        sampleFoundRoute4.route,
        sampleFoundRoute5.route,
        sampleFoundRoute6.route,
      ]);
    });

    test("newRouterPaths not contains old routes", () {
      final result = AppRouterCubitProvider().getAllRoutesToRemove(
        routerPathsToRemove: [
          RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
          RouterPaths([sampleFoundRoute3, sampleFoundRoute4]),
        ],
        newRouterPaths: RouterPaths([
          sampleFoundRoute5,
          sampleFoundRoute6,
        ]),
      );

      expect(result, [
        sampleFoundRoute1.route,
        sampleFoundRoute2.route,
        sampleFoundRoute3.route,
        sampleFoundRoute4.route,
      ]);
    });

    test("newRouterPaths contains all old routes", () {
      final result = AppRouterCubitProvider().getAllRoutesToRemove(
        routerPathsToRemove: [
          RouterPaths([sampleFoundRoute1, sampleFoundRoute2]),
          RouterPaths([sampleFoundRoute3, sampleFoundRoute4]),
        ],
        newRouterPaths: RouterPaths([
          sampleFoundRoute1,
          sampleFoundRoute2,
          sampleFoundRoute3,
          sampleFoundRoute4,
        ]),
      );

      expect(result, []);
    });
  });

  group("restoreRouteInformation", () {
    test("empty current RouterPaths", () {
      var setNewRouterPathsCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onSetNewRouterPathsCalled: () {
          setNewRouterPathsCalled = true;
        },
      );
      final newRouterPaths = RouterPaths([sampleFoundRoute1]);
      cubitProvider.restoreRouteInformation(newRouterPaths);
      expect(setNewRouterPathsCalled, true);
    });

    test("The same RouterPaths - empty", () {
      var setNewRouterPathsCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onSetNewRouterPathsCalled: () {
          setNewRouterPathsCalled = true;
        },
      );
      final newRouterPaths = RouterPaths.empty();
      cubitProvider.restoreRouteInformation(newRouterPaths);
      expect(setNewRouterPathsCalled, false);
    });

    test("The same RouterPaths - not empty", () {
      var setNewRouterPathsCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onSetNewRouterPathsCalled: () {
          setNewRouterPathsCalled = true;
        },
      );
      final newRouterPaths = RouterPaths(
        [sampleFoundRoute1, sampleFoundRoute2],
      );
      cubitProvider.setCurrentRouterPaths(newRouterPaths);
      cubitProvider.restoreRouteInformation(newRouterPaths);
      expect(setNewRouterPathsCalled, false);
    });
  });

  group("setNewRouterPaths", () {
    test("empty current RouterPaths", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      const newRouterPaths = RouterPaths([]);
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, []);
    });

    test("New current RouterPaths - empty on init", () {
      var removeUnusedProvidersCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onRemoveUnusedProvidersCalled: () => removeUnusedProvidersCalled = true,
      );
      final newRouterPaths = RouterPaths([sampleFoundRoute1]);
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, []);
      expect(cubitProvider.currentRouterPaths, newRouterPaths);
      expect(removeUnusedProvidersCalled, false);
    });

    test("New current RouterPaths - not empty on init", () {
      var removeUnusedProvidersCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onRemoveUnusedProvidersCalled: () => removeUnusedProvidersCalled = true,
      );
      final newRouterPaths = RouterPaths([sampleFoundRoute1]);
      final newRouterPaths2 = RouterPaths([sampleFoundRoute2]);
      cubitProvider.setPreviousRoutes([newRouterPaths]);
      cubitProvider.setNewRouterPaths(newRouterPaths2);
      expect(cubitProvider.previousRoutes, [newRouterPaths]);
      expect(cubitProvider.currentRouterPaths, newRouterPaths2);
      expect(removeUnusedProvidersCalled, true);
    });
  });

  group("removeUnusedProviders", () {
    test("Should dispose only old route - test 1", () {
      var name1Disposed = false;
      var name2Disposed = false;
      var name3Disposed = false;
      var name4Disposed = false;
      var name5Disposed = false;
      final sampleRoute = _MockFoundRoute("name1", onDispose: () {
        name1Disposed = true;
      });
      final cubitProvider = _MockedAppRouterCubitProvider();
      cubitProvider.setPreviousRoutes([
        RouterPaths([
          sampleRoute,
          _MockFoundRoute("name2", onDispose: () {
            name2Disposed = true;
          }),
          _MockFoundRoute("name3", onDispose: () {
            name3Disposed = true;
          }),
          _MockFoundRoute("name4", onDispose: () {
            name4Disposed = true;
          }),
          _MockFoundRoute("name5", onDispose: () {
            name5Disposed = true;
          }),
        ]),
      ]);
      cubitProvider.setCurrentRouterPaths(RouterPaths(
        [sampleRoute],
      ));
      cubitProvider.removeUnusedProviders();
      expect(cubitProvider.previousRoutes, []);
      expect(name1Disposed, false);
      expect(name2Disposed, true);
      expect(name3Disposed, true);
      expect(name4Disposed, true);
      expect(name5Disposed, true);
    });
    test("Should dispose only old route - test 2", () {
      var name1Disposed = false;
      var name2Disposed = false;
      var name3Disposed = false;
      var name4Disposed = false;
      var name5Disposed = false;
      var name6Disposed = false;
      var name7Disposed = false;
      final sampleRoute = _MockFoundRoute("name1", onDispose: () {
        name1Disposed = true;
      });
      final routerPaths = RouterPaths([
        _MockFoundRoute("name6", onDispose: () {
          name6Disposed = true;
        }),
        _MockFoundRoute("name6", onDispose: () {
          name7Disposed = true;
        }),
      ]);
      final cubitProvider = _MockedAppRouterCubitProvider();
      cubitProvider.setPreviousRoutes([
        RouterPaths([
          sampleRoute,
          _MockFoundRoute("name2", onDispose: () {
            name2Disposed = true;
          }),
          _MockFoundRoute("name3", onDispose: () {
            name3Disposed = true;
          }),
        ]),
        RouterPaths([
          sampleRoute,
          _MockFoundRoute("name4", onDispose: () {
            name4Disposed = true;
          }),
          _MockFoundRoute("name5", onDispose: () {
            name5Disposed = true;
          }),
        ]),
        routerPaths,
      ]);
      cubitProvider.setCurrentRouterPaths(RouterPaths(
        [sampleRoute],
      ));
      cubitProvider.removeUnusedProviders();
      expect(cubitProvider.previousRoutes, [routerPaths]);
      expect(name1Disposed, false);
      expect(name2Disposed, true);
      expect(name3Disposed, true);
      expect(name4Disposed, true);
      expect(name5Disposed, true);
      expect(name6Disposed, false);
      expect(name7Disposed, false);
    });
  });

  group("setNewRouterPaths", () {
    final cubitProvider = _MockedAppRouterCubitProvider();
  });
}

class _MockedAppRouterCubitProvider extends AppRouterCubitProvider {
  final VoidCallback? onSetNewRouterPathsCalled;
  final VoidCallback? onRemoveUnusedProvidersCalled;

  _MockedAppRouterCubitProvider({
    this.onSetNewRouterPathsCalled,
    this.onRemoveUnusedProvidersCalled,
  });

  @override
  void setNewRouterPaths(RouterPaths routerPaths) {
    onSetNewRouterPathsCalled?.call();
    super.setNewRouterPaths(routerPaths);
  }

  @override
  void removeUnusedProviders() {
    onRemoveUnusedProvidersCalled?.call();
    super.removeUnusedProviders();
  }
}

class _MockFoundRoute extends FoundRoute {
  _MockFoundRoute(
    String name, {
    VoidCallback? onDispose,
  }) : super.test(
          route: AppPageRoute(
            path: name,
            name: name,
            builder: (_, __) => Container(),
            onDispose: onDispose,
          ),
          fullPath: "/$name",
        );
}