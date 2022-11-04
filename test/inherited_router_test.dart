import "package:app_router/app_router.dart";
import "package:app_router/src/context_extension.dart";
import "package:app_router/src/inherited_router.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "helper/sample_pages.dart";

void main() {
  group("updateShouldNotify", () {
    test("does not update when appRouter does not change", () {
      final appRouter = AppRouter(
        errorBuilder: (_, __) => const ErrorScreen(message: ""),
        routes: [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const _Page1(),
          ),
        ],
      );
      final bool shouldNotify = _setupInheritedAppRouterChange(
        oldAppRouter: appRouter,
        newAppRouter: appRouter,
      );
      expect(shouldNotify, false);
    });

    test("updates when appRouter changes", () {
      final oldAppRouter = AppRouter(
        errorBuilder: (_, __) => const ErrorScreen(message: ""),
        routes: [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const _Page1(),
          ),
        ],
      );
      final newAppRouter = AppRouter(
        errorBuilder: (_, __) => const ErrorScreen(message: ""),
        routes: [
          AppPageRoute(
            path: "/",
            name: "start",
            builder: (_, __) => const _Page2(),
          ),
        ],
      );
      final bool shouldNotify = _setupInheritedAppRouterChange(
        oldAppRouter: oldAppRouter,
        newAppRouter: newAppRouter,
      );
      expect(shouldNotify, true);
    });
  });

  testWidgets("mediates Widget's access to AppRouter.",
      (WidgetTester tester) async {
    final router = _MockAppRouter();
    await tester.pumpWidget(
      MaterialApp(
        home: InheritedAppRouter(
          appRouter: router,
          child: const _MyWidget(),
        ),
      ),
    );
    await tester.tap(find.text("My Page"));
    expect(router.latestPushedName, "my_page");
  });
}

bool _setupInheritedAppRouterChange({
  required AppRouter oldAppRouter,
  required AppRouter newAppRouter,
}) {
  final oldInheritedGoRouter = InheritedAppRouter(
    appRouter: oldAppRouter,
    child: Container(),
  );
  final newInheritedGoRouter = InheritedAppRouter(
    appRouter: newAppRouter,
    child: Container(),
  );
  return newInheritedGoRouter.updateShouldNotify(
    oldInheritedGoRouter,
  );
}

class _Page1 extends StatelessWidget {
  const _Page1({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class _Page2 extends StatelessWidget {
  const _Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

class _MyWidget extends StatelessWidget {
  const _MyWidget();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.pushNamed("my_page"),
      child: const Text("My Page"),
    );
  }
}

class _MockAppRouter extends AppRouter {
  _MockAppRouter()
      : super(
          routes: [],
          errorBuilder: (_, __) => const ErrorScreen(message: ""),
        );

  late String latestPushedName;

  @override
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  }) {
    latestPushedName = name;
    return SynchronousFuture(null);
  }

  @override
  BackButtonDispatcher get backButtonDispatcher => RootBackButtonDispatcher();
}
