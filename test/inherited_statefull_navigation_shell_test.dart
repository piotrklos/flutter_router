import "package:app_router/app_router.dart";
import 'package:app_router/src/inherited_statefull_navigation_shell.dart';
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import 'helper/sample_routes.dart';

void main() {
  group("updateShouldNotify", () {
    test("does not update when appRouter does not change", () {
      final state = StatefulShellRouteState(
        changeActiveBranch: (_, __) {},
        branchStates: const [],
        currentIndex: 1,
        route: StatefulShellRoute.rootRoutes(
          builder: (_, __, child) => child,
          routes: [
            SampleRoutes.routePage1,
          ],
        ),
      );
      final bool shouldNotify = _setupInheritedStatefulNavigationShellChange(
        newState: state,
        oldState: state,
      );
      expect(shouldNotify, false);
    });

    test("updates when appRouter changes", () {
      final oldState = StatefulShellRouteState(
        changeActiveBranch: (_, __) {},
        branchStates: const [],
        currentIndex: 1,
        route: StatefulShellRoute.rootRoutes(
          builder: (_, __, child) => child,
          routes: [
            SampleRoutes.routePage1,
          ],
        ),
      );
      final newState = StatefulShellRouteState(
        changeActiveBranch: (_, __) {},
        branchStates: const [],
        currentIndex: 2,
        route: StatefulShellRoute.rootRoutes(
          builder: (_, __, child) => child,
          routes: [
            SampleRoutes.routePage2,
          ],
        ),
      );
      final bool shouldNotify = _setupInheritedStatefulNavigationShellChange(
        newState: newState,
        oldState: oldState,
      );
      expect(shouldNotify, true);
    });
  });

  testWidgets("mediates Widget's access to AppRouter.", (
    WidgetTester tester,
  ) async {
    final shellRoute1 = ShellRouteBranch(
      rootRoute: SampleRoutes.routePage1,
    );
    final shellRoute2 = ShellRouteBranch(
      rootRoute: SampleRoutes.routePage2,
    );
    final state1 = ShellRouteBranchState(
      rootRoutePath: const AppRouterLocation(name: "name", path: "path"),
      routeBranch: shellRoute1,
    );
    final state2 = ShellRouteBranchState(
      rootRoutePath: const AppRouterLocation(name: "name", path: "path"),
      routeBranch: shellRoute2,
    );
    final state = StatefulShellRouteState(
      changeActiveBranch: (state, __) {
        expect(state, state2);
      },
      branchStates: [state1, state2],
      currentIndex: 1,
      route: StatefulShellRoute(
        builder: (_, __, child) => child,
        branches: [shellRoute1, shellRoute2],
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: InheritedStatefulNavigationShell(
          routeState: state,
          child: const _MyWidget(),
        ),
      ),
    );
    await tester.tap(find.text("My Page"));
    expect(state.currentIndex, 1);
  });
}

bool _setupInheritedStatefulNavigationShellChange({
  required StatefulShellRouteState oldState,
  required StatefulShellRouteState newState,
}) {
  final oldInheritedAppRouter = InheritedStatefulNavigationShell(
    routeState: oldState,
    child: Container(),
  );
  final newInheritedAppRouter = InheritedStatefulNavigationShell(
    routeState: newState,
    child: Container(),
  );
  return newInheritedAppRouter.updateShouldNotify(
    oldInheritedAppRouter,
  );
}

class _MyWidget extends StatelessWidget {
  const _MyWidget();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        StatefulShellRoute.of(context).goToBranch(1);
      },
      child: const Text("My Page"),
    );
  }
}
