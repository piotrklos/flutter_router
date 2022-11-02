import 'dart:async';

import 'package:app_router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper/helper.dart';
import 'helper/sample_routes.dart';

void main() {
  setUp(() {
    SampleRoutes.clearStreamController();
  });
  group("commonRoutes", () {
    test("All empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.commonRoutes(
        previousRoute: RouterPaths.empty(),
        newRouterPaths: RouterPaths.empty(),
      );
      expect(result, []);
    });

    test("Previous empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.commonRoutes(
        previousRoute: RouterPaths.empty(),
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.routePage1],
        ),
      );
      expect(result, []);
    });

    test("New empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.commonRoutes(
        newRouterPaths: RouterPaths.empty(),
        previousRoute: TestHelper.createRouterPaths(
          [SampleRoutes.routePage1],
        ),
      );
      expect(result, []);
    });

    test("One common route", () {
      final route1 = SampleRoutes.routePage1;
      final route2 = SampleRoutes.routePage1Child1;
      final route3 = SampleRoutes.routePage1Child1Child;
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.commonRoutes(
        previousRoute: TestHelper.createRouterPaths(
          [route1, route2, route3],
        ),
        newRouterPaths: TestHelper.createRouterPaths(
          [route1],
        ),
      );
      expect(result, [route1]);
    });

    test("Many common route", () {
      final route1 = SampleRoutes.routePage1;
      final route2 = SampleRoutes.routePage1Child1;
      final route3 = SampleRoutes.routePage1Child1Child;
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.commonRoutes(
        previousRoute: TestHelper.createRouterPaths(
          [route1, route2, route3],
        ),
        newRouterPaths: TestHelper.createRouterPaths(
          [route1, route2],
        ),
      );
      expect(result, [route1, route2]);
    });

    test("No common route", () {
      final route1 = SampleRoutes.routePage1;
      final route2 = SampleRoutes.routePage1Child1;
      final route3 = SampleRoutes.routePage1Child1Child;
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.commonRoutes(
        previousRoute: TestHelper.createRouterPaths(
          [route1, route2, route3],
        ),
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.routePage2, SampleRoutes.routePage2Child1],
        ),
      );
      expect(result, []);
    });

    test("One common route - shell", () {
      final shellRoute = SampleRoutes.shellRoute;
      final route1 = SampleRoutes.routePage1;
      final route2 = SampleRoutes.routePage1Child1;
      final route3 = SampleRoutes.routePage1Child1Child;

      final cubitProvider = _MockedAppRouterCubitProvider();

      final result = cubitProvider.commonRoutes(
        previousRoute: TestHelper.createRouterPaths(
          [shellRoute, route1, route2, route3],
        ),
        newRouterPaths: TestHelper.createRouterPaths(
          [shellRoute, SampleRoutes.routePage2, SampleRoutes.routePage2Child1],
        ),
      );
      expect(result, [shellRoute]);
    });
  });

  group("getAllRouterPathsToRemove", () {
    test("All empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRouterPathsToRemove(
        previousRoutes: [],
        newRouterPaths: RouterPaths.empty(),
      );
      expect(result, []);
    });

    test("Previous empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRouterPathsToRemove(
        previousRoutes: [],
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.routePage1],
        ),
      );
      expect(result, []);
    });

    test("New empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRouterPathsToRemove(
        newRouterPaths: RouterPaths.empty(),
        previousRoutes: [
          TestHelper.createRouterPaths([SampleRoutes.routePage1]),
        ],
      );
      expect(result, []);
    });

    test("No path to remove form common shell route", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRouterPathsToRemove(
        newRouterPaths: TestHelper.createRouterPaths([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
        ]),
        previousRoutes: [
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage2,
          ]),
        ],
      );
      expect(result, []);
    });

    test("No path to remove form common shell route - test 2", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRouterPathsToRemove(
        newRouterPaths: TestHelper.createRouterPaths([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1,
        ]),
        previousRoutes: [
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage2,
          ]),
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage3,
            SampleRoutes.routePage3Child1,
          ]),
        ],
      );
      expect(result, []);
    });

    test("Should remove unsued paths", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final prevPaths1 = TestHelper.createRouterPaths([
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1,
      ]);
      final prevPaths2 = TestHelper.createRouterPaths([
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      final result = cubitProvider.getAllRouterPathsToRemove(
        newRouterPaths: TestHelper.createRouterPaths([
          SampleRoutes.routePage3,
          SampleRoutes.routePage3Child1,
        ]),
        previousRoutes: [prevPaths1, prevPaths2],
      );
      expect(result, [prevPaths1, prevPaths2]);
    });

    test("Should remove unsued paths with common shellRoutes", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final prevPaths3 = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage3,
      ]);
      final result = cubitProvider.getAllRouterPathsToRemove(
        newRouterPaths: TestHelper.createRouterPaths([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage3,
          SampleRoutes.routePage3Child1,
        ]),
        previousRoutes: [
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage2,
            SampleRoutes.routePage2Child1,
          ]),
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage1,
            SampleRoutes.routePage1Child1,
          ]),
          prevPaths3,
        ],
      );
      expect(result, [prevPaths3]);
    });

    test("Should remove unsued paths with common shellRoutes", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final prevPaths3 = TestHelper.createRouterPaths([
        SampleRoutes.routePage3,
      ]);
      final prevPaths2 = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage2,
      ]);
      final result = cubitProvider.getAllRouterPathsToRemove(
        newRouterPaths: TestHelper.createRouterPaths([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage2,
          SampleRoutes.routePage2Child1,
        ]),
        previousRoutes: [
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage1,
            SampleRoutes.routePage1Child1,
          ]),
          prevPaths3,
          prevPaths2,
        ],
      );
      expect(result, [prevPaths3, prevPaths2]);
    });
  });

  group("getAllRoutesToRemove", () {
    test("All empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRoutesToRemove(
        routerPathsToRemove: [],
        newRouterPaths: RouterPaths.empty(),
      );
      expect(result, []);
    });

    test("RouterPathsToRemove empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRoutesToRemove(
        routerPathsToRemove: [],
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.routePage1],
        ),
      );
      expect(result, []);
    });

    test("NewRouterPaths empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRoutesToRemove(
        routerPathsToRemove: [
          TestHelper.createRouterPaths(
            [SampleRoutes.routePage1],
          ),
        ],
        newRouterPaths: RouterPaths.empty(),
      );
      expect(result, [SampleRoutes.routePage1]);
    });

    test("Three routes to remove", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRoutesToRemove(
        routerPathsToRemove: [
          TestHelper.createRouterPaths(
            [SampleRoutes.routePage1, SampleRoutes.routePage1Child1],
          ),
          TestHelper.createRouterPaths(
            [SampleRoutes.routePage2, SampleRoutes.routePage2Child1],
          ),
        ],
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.routePage1],
        ),
      );
      expect(result, [
        SampleRoutes.routePage1Child1,
        SampleRoutes.routePage2Child1,
        SampleRoutes.routePage2,
      ]);
    });

    test("Two routes to remove", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRoutesToRemove(
        routerPathsToRemove: [
          TestHelper.createRouterPaths(
            [SampleRoutes.routePage1, SampleRoutes.routePage1Child1],
          ),
          TestHelper.createRouterPaths(
            [SampleRoutes.routePage1, SampleRoutes.routePage1Child1Child],
          ),
        ],
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.routePage1],
        ),
      );
      expect(result, [
        SampleRoutes.routePage1Child1,
        SampleRoutes.routePage1Child1Child,
      ]);
    });

    test("Two routes to remove with ShellRoute", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final result = cubitProvider.getAllRoutesToRemove(
        routerPathsToRemove: [
          TestHelper.createRouterPaths(
            [
              SampleRoutes.shellRoute,
              SampleRoutes.routePage1,
              SampleRoutes.routePage1Child1,
            ],
          ),
          TestHelper.createRouterPaths(
            [
              SampleRoutes.shellRoute,
              SampleRoutes.routePage1,
              SampleRoutes.routePage1Child1Child
            ],
          ),
        ],
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.shellRoute, SampleRoutes.routePage1],
        ),
      );
      expect(result, [
        SampleRoutes.routePage1Child1,
        SampleRoutes.routePage1Child1Child,
      ]);
    });

    test("Shoukd remove all previous routes", () {
      final cubitProvider = _MockedAppRouterCubitProvider();

      final result = cubitProvider.getAllRoutesToRemove(
        routerPathsToRemove: [
          TestHelper.createRouterPaths(
            [
              SampleRoutes.shellRoute,
              SampleRoutes.routePage1,
              SampleRoutes.routePage1Child1,
            ],
          ),
          TestHelper.createRouterPaths(
            [
              SampleRoutes.shellRoute,
              SampleRoutes.routePage2,
              SampleRoutes.routePage2Child1
            ],
          ),
        ],
        newRouterPaths: TestHelper.createRouterPaths(
          [SampleRoutes.routePage3],
        ),
      );
      expect(result, [
        SampleRoutes.routePage1Child1,
        SampleRoutes.routePage1,
        SampleRoutes.shellRoute,
        SampleRoutes.routePage2Child1,
        SampleRoutes.routePage2,
      ]);
    });
  });

  group("removeUnusedProviders", () {
    test("Should call other function", () {
      var getAllRouterPathsToRemoveCalled = false;
      var getAllRoutesToRemoveCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onGetAllRouterPathsToRemoveCalled: () {
          getAllRouterPathsToRemoveCalled = true;
        },
        onGetAllRoutesToRemoveCalled: () {
          getAllRoutesToRemoveCalled = true;
        },
      );
      cubitProvider.removeUnusedProviders();
      expect(getAllRouterPathsToRemoveCalled, true);
      expect(getAllRoutesToRemoveCalled, true);
    });

    test("All empty", () {
      final cubitProvider = _MockedAppRouterCubitProvider();
      cubitProvider.removeUnusedProviders();
      expect(cubitProvider.previousRoutes, []);
    });

    test("Previous routes empty", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);
      cubitProvider.setPreviousRoutes(
        [],
      );
      cubitProvider.setCurrentRouterPaths(
        TestHelper.createRouterPaths([SampleRoutes.routePage1]),
      );
      cubitProvider.removeUnusedProviders();
      controller.close();
      expect(await controller.stream.toList(), []);
    });

    test("Should pop unused route", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);
      cubitProvider.setPreviousRoutes(
        [
          TestHelper.createRouterPaths(
            [SampleRoutes.routePage1, SampleRoutes.routePage1Child1],
          ),
          TestHelper.createRouterPaths(
            [SampleRoutes.routePage2, SampleRoutes.routePage2Child1],
          ),
        ],
      );
      cubitProvider.setCurrentRouterPaths(
        TestHelper.createRouterPaths([SampleRoutes.routePage1]),
      );
      cubitProvider.removeUnusedProviders();
      controller.close();
      expect(await controller.stream.toList(), [
        "routePage1Child1 onPop",
        "routePage2Child1 onPop",
        "routePage2 onPop",
      ]);
    });

    test("Should pop unused route with shell route", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);
      cubitProvider.setPreviousRoutes(
        [
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage1,
            SampleRoutes.routePage1Child1,
          ]),
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage2,
            SampleRoutes.routePage2Child1,
          ]),
        ],
      );
      cubitProvider.setCurrentRouterPaths(
        TestHelper.createRouterPaths([
          SampleRoutes.shellRoute,
          SampleRoutes.routePage1,
        ]),
      );
      cubitProvider.removeUnusedProviders();
      controller.close();
      expect(await controller.stream.toList(), [
        "routePage1Child1 onPop",
      ]);
    });

    test("Should pop unused route with shell route - test 2", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);
      cubitProvider.setPreviousRoutes(
        [
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage1,
            SampleRoutes.routePage1Child1,
          ]),
          TestHelper.createRouterPaths([
            SampleRoutes.shellRoute,
            SampleRoutes.routePage2,
            SampleRoutes.routePage2Child1,
          ]),
        ],
      );
      cubitProvider.setCurrentRouterPaths(
        TestHelper.createRouterPaths([
          SampleRoutes.routePage3,
        ]),
      );
      cubitProvider.removeUnusedProviders();
      controller.close();
      expect(await controller.stream.toList(), [
        "routePage1Child1 onPop",
        "routePage1 onPop",
        "shellRoute onPop",
        "routePage2Child1 onPop",
        "routePage2 onPop",
      ]);
    });
  });

  group("setNewProviders", () {
    test("All empty", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);

      cubitProvider.setCurrentRouterPaths(RouterPaths.empty());
      cubitProvider.setNewProviders();
      controller.close();
      expect(await controller.stream.toList(), []);
    });

    test("should call onPush", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);

      cubitProvider.setCurrentRouterPaths(TestHelper.createRouterPaths([
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]));
      cubitProvider.setNewProviders();
      controller.close();
      expect(await controller.stream.toList(), [
        "routePage1 onPush",
        "routePage1Child1Child onPush",
      ]);
    });
    test("should call onPush - test 2", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);

      cubitProvider.setCurrentRouterPaths(TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]));
      cubitProvider.setNewProviders();
      controller.close();
      expect(await controller.stream.toList(), [
        "routePage1 onPush",
        "routePage1Child1Child onPush",
      ]);
    });

    test("should call onPush - test 3", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);

      cubitProvider.setCurrentRouterPaths(TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage1,
      ]));
      cubitProvider.setNewProviders();
      controller.close();
      expect(await controller.stream.toList(), [
        "routePage1 onPush",
      ]);
    });
    test("should call onPush - test 4", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final controller = StreamController<String>();
      SampleRoutes.setNewStreamController(controller);

      cubitProvider.setCurrentRouterPaths(TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
      ]));
      cubitProvider.setNewProviders();
      controller.close();
      expect(await controller.stream.toList(), []);
    });
  });

  group("setNewRouterPaths", () {
    test("should not call other function is new RouterPaths is empty",
        () async {
      var setNewProvidersCalled = false;
      var removeUnusedProvidersCalled = false;
      final cubitProvider =
          _MockedAppRouterCubitProvider(onSetNewProvidersCalled: () {
        setNewProvidersCalled = true;
      }, onRemoveUnusedProvidersCalled: () {
        removeUnusedProvidersCalled = true;
      });
      cubitProvider.setNewRouterPaths(
        RouterPaths.empty(),
      );
      expect(setNewProvidersCalled, false);
      expect(removeUnusedProvidersCalled, false);
    });

    test("should call only setNewProviders - previousRoutes is empty",
        () async {
      var setNewProvidersCalled = false;
      var removeUnusedProvidersCalled = false;
      final cubitProvider =
          _MockedAppRouterCubitProvider(onSetNewProvidersCalled: () {
        setNewProvidersCalled = true;
      }, onRemoveUnusedProvidersCalled: () {
        removeUnusedProvidersCalled = true;
      });
      cubitProvider.setPreviousRoutes([]);
      cubitProvider.setNewRouterPaths(
        TestHelper.createRouterPaths([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1Child,
        ]),
      );
      expect(setNewProvidersCalled, true);
      expect(removeUnusedProvidersCalled, false);
    });

    test("should call setNewProviders and removeUnusedProviders", () async {
      var setNewProvidersCalled = false;
      var removeUnusedProvidersCalled = false;
      final cubitProvider =
          _MockedAppRouterCubitProvider(onSetNewProvidersCalled: () {
        setNewProvidersCalled = true;
      }, onRemoveUnusedProvidersCalled: () {
        removeUnusedProvidersCalled = true;
      });
      cubitProvider.setPreviousRoutes([
        TestHelper.createRouterPaths([
          SampleRoutes.routePage1,
        ]),
      ]);
      cubitProvider.setNewRouterPaths(
        TestHelper.createRouterPaths([
          SampleRoutes.routePage1,
          SampleRoutes.routePage1Child1Child,
        ]),
      );
      expect(setNewProvidersCalled, true);
      expect(removeUnusedProvidersCalled, true);
    });

    test("should set correct config - empty previous and current", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final newRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]);
      cubitProvider.setPreviousRoutes([]);
      cubitProvider.setCurrentRouterPaths(RouterPaths.empty());
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, []);
      expect(cubitProvider.currentRouterPaths, newRouterPaths);
    });

    test("should set correct config - empty previous", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final currentRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      final newRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]);
      cubitProvider.setPreviousRoutes([]);
      cubitProvider.setCurrentRouterPaths(currentRouterPaths);
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, []);
      expect(cubitProvider.currentRouterPaths, newRouterPaths);
    });

    test("should set correct config - empty previous - test 2", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final currentRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      final newRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]);
      cubitProvider.setPreviousRoutes([]);
      cubitProvider.setCurrentRouterPaths(currentRouterPaths);
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, [currentRouterPaths]);
      expect(cubitProvider.currentRouterPaths, newRouterPaths);
    });

    test("should set correct config - with previous", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final currentRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      final previousRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage3,
        SampleRoutes.routePage3Child1,
      ]);
      final newRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]);
      cubitProvider.setPreviousRoutes([previousRouterPaths]);
      cubitProvider.setCurrentRouterPaths(currentRouterPaths);
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, [
        previousRouterPaths,
        currentRouterPaths,
      ]);
      expect(cubitProvider.currentRouterPaths, newRouterPaths);
    });

    test("should set correct config - with previous - test 2", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final currentRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      final previousRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage3,
        SampleRoutes.routePage3Child1,
      ]);
      final newRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]);
      cubitProvider.setPreviousRoutes([previousRouterPaths]);
      cubitProvider.setCurrentRouterPaths(currentRouterPaths);
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, []);
      expect(cubitProvider.currentRouterPaths, newRouterPaths);
    });

    test("should set correct config - with previous - test 3", () async {
      final cubitProvider = _MockedAppRouterCubitProvider();
      final previousRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      final currentRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage3,
        SampleRoutes.routePage3Child1,
      ]);
      final newRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.shellRoute,
        SampleRoutes.routePage1,
        SampleRoutes.routePage1Child1Child,
      ]);
      cubitProvider.setPreviousRoutes([previousRouterPaths]);
      cubitProvider.setCurrentRouterPaths(currentRouterPaths);
      cubitProvider.setNewRouterPaths(newRouterPaths);
      expect(cubitProvider.previousRoutes, [currentRouterPaths]);
      expect(cubitProvider.currentRouterPaths, newRouterPaths);
    });
  });

  group("restoreRouteInformation", () {
    test(
        "should not call other function if new RouterPaths is the same as previous",
        () async {
      var setNewProvidersCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onSetNewProvidersCalled: () {
          setNewProvidersCalled = true;
        },
      );
      final sampleRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      cubitProvider.setCurrentRouterPaths(sampleRouterPaths);
      cubitProvider.restoreRouteInformation(sampleRouterPaths);
      expect(setNewProvidersCalled, false);
    });

    test("should call setNewRouterPaths", () async {
      var setNewRouterPathsCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onSetNewRouterPathsCalled: () {
          setNewRouterPathsCalled = true;
        },
      );
      final sampleRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      cubitProvider.setCurrentRouterPaths(RouterPaths.empty());
      cubitProvider.restoreRouteInformation(sampleRouterPaths);
      expect(setNewRouterPathsCalled, true);
    });

    test("should call setNewRouterPaths - test 2", () async {
      var setNewRouterPathsCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onSetNewRouterPathsCalled: () {
          setNewRouterPathsCalled = true;
        },
      );
      final sampleRouterPaths = TestHelper.createRouterPaths([
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]);
      cubitProvider.setCurrentRouterPaths(sampleRouterPaths);
      cubitProvider.restoreRouteInformation(RouterPaths.empty());
      expect(setNewRouterPathsCalled, true);
    });

    test("should call setNewRouterPaths - test 2", () async {
      var setNewRouterPathsCalled = false;
      final cubitProvider = _MockedAppRouterCubitProvider(
        onSetNewRouterPathsCalled: () {
          setNewRouterPathsCalled = true;
        },
      );

      cubitProvider.setCurrentRouterPaths(
        TestHelper.createRouterPaths([
          SampleRoutes.routePage2,
        ]),
      );
      cubitProvider.restoreRouteInformation(TestHelper.createRouterPaths([
        SampleRoutes.routePage2,
        SampleRoutes.routePage2Child1,
      ]));
      expect(setNewRouterPathsCalled, true);
    });
  });
}

class _MockedAppRouterCubitProvider extends AppRouterCubitProvider {
  final VoidCallback? onSetNewRouterPathsCalled;
  final VoidCallback? onRemoveUnusedProvidersCalled;
  final VoidCallback? onGetAllRouterPathsToRemoveCalled;
  final VoidCallback? onGetAllRoutesToRemoveCalled;
  final VoidCallback? onSetNewProvidersCalled;

  _MockedAppRouterCubitProvider({
    this.onSetNewRouterPathsCalled,
    this.onRemoveUnusedProvidersCalled,
    this.onGetAllRouterPathsToRemoveCalled,
    this.onGetAllRoutesToRemoveCalled,
    this.onSetNewProvidersCalled,
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

  @override
  void setNewProviders() {
    onSetNewProvidersCalled?.call();
    super.setNewProviders();
  }

  @override
  List<BaseAppRoute> getAllRoutesToRemove({
    required List<RouterPaths> routerPathsToRemove,
    required RouterPaths newRouterPaths,
  }) {
    onGetAllRoutesToRemoveCalled?.call();
    return super.getAllRoutesToRemove(
      routerPathsToRemove: routerPathsToRemove,
      newRouterPaths: newRouterPaths,
    );
  }

  @override
  List<RouterPaths> getAllRouterPathsToRemove({
    required List<RouterPaths> previousRoutes,
    required RouterPaths newRouterPaths,
  }) {
    onGetAllRouterPathsToRemoveCalled?.call();
    return super.getAllRouterPathsToRemove(
      newRouterPaths: newRouterPaths,
      previousRoutes: previousRoutes,
    );
  }
}
