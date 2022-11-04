import 'dart:async';

import "package:app_router/src/app_router.dart";
import "package:app_router/src/route.dart";
import 'package:app_router/src/router_exception.dart';
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  Future<AppRouter> _createRouter(
    WidgetTester tester, {
    Listenable? refreshListenable,
  }) async {
    final router = AppRouter(
      initialLocation: "/",
      routes: [
        AppPageRoute(
          path: "/",
          name: "start",
          builder: (_, __) => const _TestStetefullWidget(),
        ),
        AppPageRoute(
          path: "/a",
          name: "a",
          builder: (_, __) => const _TestStetefullWidget(),
          routes: [
            AppPageRoute(
              path: "c",
              name: "c",
              builder: (_, __) => const _TestStetefullWidget(),
            ),
          ],
        ),
        AppPageRoute(
          path: "/b",
          name: "b",
          builder: (_, __) => const _TestStetefullWidget(),
        ),
      ],
      errorBuilder: (_, __) {
        return const Text("Error Widget");
      },
      refreshListenable: refreshListenable,
    );
    await tester.pumpWidget(MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: router.backButtonDispatcher,
    ));
    return router;
  }

  group("pop", () {
    testWidgets("removes the last element", (WidgetTester tester) async {
      final router = await _createRouter(tester);
      router.push("/b");

      await tester.pumpAndSettle();

      router.routerDelegate.addListener(expectAsync0(() {}));

      final last = router.routerDelegate.routerPaths.allRoutes.last;
      router.routerDelegate.pop();
      expect(router.routerDelegate.routerPaths.length, 1);
      expect(router.routerDelegate.routerPaths.allRoutes.contains(last), false);
    });

    testWidgets("Should pop to parent route", (WidgetTester tester) async {
      final router = await _createRouter(tester);
      router.routerDelegate.addListener(expectAsync0(() {}));

      router.go("/b");
      await tester.pumpAndSettle();
      final parentRoutes = router.routerDelegate.routerPaths;
      router.go("/a/c", backToParent: true);
      await tester.pumpAndSettle();

      router.routerDelegate.pop();
      expect(router.routerDelegate.routerPaths, parentRoutes);
    });

    testWidgets("Should pop to parent route with object",
        (WidgetTester tester) async {
      final router = await _createRouter(tester);
      router.routerDelegate.addListener(expectAsync0(() {}));
      final object = Object();
      final completer = Completer<Object>();

      router.go("/b");
      await tester.pumpAndSettle();
      final parentRoutes = router.routerDelegate.routerPaths;

      router.go("/a/c", backToParent: true).then((value) {
        completer.complete(value);
      });
      await tester.pumpAndSettle();

      router.routerDelegate.pop(object);
      expect(router.routerDelegate.routerPaths, parentRoutes);
      final result = await completer.future;
      expect(result, object);
    });

    testWidgets("Should pop to previous route with object",
        (WidgetTester tester) async {
      final router = await _createRouter(tester);
      router.routerDelegate.addListener(expectAsync0(() {}));
      final object = Object();
      final completer = Completer<Object>();

      router.go("/a");
      await tester.pumpAndSettle();
      final parentRoutes = router.routerDelegate.routerPaths;

      router.go("/a/c").then((value) {
        completer.complete(value);
      });
      await tester.pumpAndSettle();

      router.routerDelegate.pop(object);
      expect(router.routerDelegate.routerPaths, parentRoutes);
      final result = await completer.future;
      expect(result, object);
    });

    testWidgets("throws AppRouterException when pops last page on stack",
        (WidgetTester tester) async {
      final router = await _createRouter(tester);
      router.push("/b");
      await tester.pumpAndSettle();
      expect(
        () => router.routerDelegate
          ..pop()
          ..pop(),
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

  group("push", () {
    testWidgets(
      "Should contain different pakKey if push was called multiple times for this same route",
      (WidgetTester tester) async {
        final router = await _createRouter(tester);

        expect(router.routerDelegate.routerPaths.length, 1);
        expect(
          router.routerDelegate.routerPaths.routeForIndex(0)?.pageKey,
          null,
        );

        router.push("/a");
        await tester.pumpAndSettle();

        expect(router.routerDelegate.routerPaths.length, 2);
        expect(
          router.routerDelegate.routerPaths.routeForIndex(1)?.pageKey,
          const Key("/a-count:1"),
        );

        router.push("/a");
        await tester.pumpAndSettle();

        expect(router.routerDelegate.routerPaths.length, 3);
        expect(
          router.routerDelegate.routerPaths.routeForIndex(2)?.pageKey,
          const Key("/a-count:2"),
        );
      },
    );
  });

  group("canPop", () {
    testWidgets(
      "Should return false if only 1 paths in the stack",
      (WidgetTester tester) async {
        final router = await _createRouter(tester);

        await tester.pumpAndSettle();
        expect(router.routerDelegate.routerPaths.length, 1);
        expect(router.routerDelegate.canPop(), false);
      },
    );

    testWidgets(
      "Should return true if more than 1 paths in the stack",
      (WidgetTester tester) async {
        final router = await _createRouter(tester);
        router.push("/a");

        await tester.pumpAndSettle();
        expect(router.routerDelegate.routerPaths.length, 2);
        expect(router.routerDelegate.canPop(), true);
      },
    );
  });

  testWidgets("dispose unsubscribes from refreshListenable", (
    WidgetTester tester,
  ) async {
    final FakeRefreshListenable refreshListenable = FakeRefreshListenable();
    final router = await _createRouter(
      tester,
      refreshListenable: refreshListenable,
    );
    await tester.pumpWidget(Container());
    router.dispose();
    expect(refreshListenable.unsubscribed, true);
  });
}

class FakeRefreshListenable extends ChangeNotifier {
  bool unsubscribed = false;

  @override
  void removeListener(VoidCallback listener) {
    unsubscribed = true;
    super.removeListener(listener);
  }
}

class _TestStetefullWidget extends StatefulWidget {
  const _TestStetefullWidget({Key? key}) : super(key: key);

  @override
  State<_TestStetefullWidget> createState() => __TestStetefullWidgetState();
}

class __TestStetefullWidgetState extends State<_TestStetefullWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
