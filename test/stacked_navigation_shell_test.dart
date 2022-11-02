import 'package:app_router/app_router_location.dart';
import 'package:app_router/app_router_router.dart';
import 'package:app_router/inherited_router.dart';
import 'package:app_router/stacked_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper/mock_app_router.dart';

void main() {
  final AppRouter appRouter = MockAppRouter();
  testWidgets("Should correct build StackedNavigationShell", (tester) async {
    final keyA = GlobalKey<NavigatorState>();
    final keyB = GlobalKey<NavigatorState>();
    final widget = MaterialApp(
      home: StackedNavigationShell(
        currentNavigator: Navigator(
          key: keyA,
          pages: const [
            MaterialPage(
              child: Text("Widget A"),
              name: "a",
            ),
          ],
          onPopPage: (_, __) {
            return true;
          },
        ),
        stackItems: [
          StackedNavigationItem(
            navigatorKey: keyA,
            rootRouteLocation: AppRouterLocation(name: "a", path: "/a"),
          ),
          StackedNavigationItem(
            navigatorKey: keyB,
            rootRouteLocation: AppRouterLocation(name: "b", path: "/b"),
          ),
        ],
      ),
    );
    await tester.pumpWidget(widget);
    final textA = find.text("Widget A");
    final textB = find.text("Widget B");
    expect(textA, findsOneWidget);
    expect(textB, findsNothing);
  }, skip: true);

  testWidgets("Should updated correctly", (tester) async {
    final keyA = GlobalKey<NavigatorState>();
    final keyB = GlobalKey<NavigatorState>();
    final widget = MaterialApp(
      home: InheritedAppRouter(
        appRouter: appRouter,
        child: StackedNavigationShell(
          currentNavigator: Navigator(
            key: keyA,
            pages: const [
              MaterialPage(
                child: Text("Widget A"),
                name: "a",
              ),
            ],
            onPopPage: (_, __) {
              return true;
            },
          ),
          stackItems: [
            StackedNavigationItem(
              navigatorKey: keyA,
              rootRouteLocation: AppRouterLocation(name: "a", path: "/a"),
            ),
            StackedNavigationItem(
              navigatorKey: keyB,
              rootRouteLocation: AppRouterLocation(name: "b", path: "/b"),
            ),
          ],
        ),
      ),
    );
    await tester.pumpWidget(widget);
    final textA = find.text("Widget A");
    final textB = find.text("Widget B");
    expect(textA, findsOneWidget);
    expect(textB, findsNothing);
  }, skip: true);
}
