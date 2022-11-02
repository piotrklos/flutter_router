import 'package:app_router/app_router_builder_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("isMaterialApp", () {
    testWidgets("should return true", (tester) async {
      final helper = AppRouterBuilderHelper();

      final key = GlobalKey<__TestStetefullWidgetState>();
      await tester.pumpWidget(
        MaterialApp(
          home: _TestStetefullWidget(key: key),
        ),
      );
      final bool isCupertino = helper.isMaterialApp(
        key.currentContext! as Element,
      );
      expect(isCupertino, true);
    });

    testWidgets("should return false", (tester) async {
      final helper = AppRouterBuilderHelper();

      final key = GlobalKey<__TestStetefullWidgetState>();
      await tester.pumpWidget(
        CupertinoApp(
          home: _TestStetefullWidget(key: key),
        ),
      );
      final bool isCupertino = helper.isMaterialApp(
        key.currentContext! as Element,
      );
      expect(isCupertino, false);
    });
  });

  group("isCupertinoApp", () {
    testWidgets("should return true", (tester) async {
      final helper = AppRouterBuilderHelper();

      final key = GlobalKey<__TestStetefullWidgetState>();
      await tester.pumpWidget(
        CupertinoApp(
          home: _TestStetefullWidget(key: key),
        ),
      );
      final bool isCupertino = helper.isCupertinoApp(
        key.currentContext! as Element,
      );
      expect(isCupertino, true);
    });

    testWidgets("should return false", (tester) async {
      final helper = AppRouterBuilderHelper();

      final key = GlobalKey<__TestStetefullWidgetState>();
      await tester.pumpWidget(
        MaterialApp(
          home: _TestStetefullWidget(key: key),
        ),
      );
      final bool isCupertino = helper.isCupertinoApp(
        key.currentContext! as Element,
      );
      expect(isCupertino, false);
    });
  });

  test("pageBuilderForCupertinoApp", () {
    final helper = AppRouterBuilderHelper();
    final child = Container();
    final page = helper.pageBuilderForCupertinoApp(
      child: child,
      key: const ValueKey("Key"),
      name: "TestName",
      restorationId: "restorationId",
    );

    expect(page, const TypeMatcher<CupertinoPage>());
    expect(page.child, child);
    expect(page.key, const ValueKey("Key"));
    expect(page.name, "TestName");
    expect(page.restorationId, "restorationId");
  });

  test("pageBuilderForMaterialApp", () {
    final helper = AppRouterBuilderHelper();
    final child = Container();
    final page = helper.pageBuilderForMaterialApp(
      child: child,
      key: const ValueKey("Key"),
      name: "TestName",
      restorationId: "restorationId",
    );

    expect(page, const TypeMatcher<MaterialPage>());
    expect(page.child, child);
    expect(page.key, const ValueKey("Key"));
    expect(page.name, "TestName");
    expect(page.restorationId, "restorationId");
  });

  test("pageBuilderForWidgetApp", () {
    final helper = AppRouterBuilderHelper();
    final child = Container();
    final page = helper.pageBuilderForWidgetApp(
      child: child,
      key: const ValueKey("Key"),
      name: "TestName",
      restorationId: "restorationId",
    );

    expect(page, const TypeMatcher<NoTransitionPage>());
    expect((page as NoTransitionPage).child, child);
    expect(page.key, const ValueKey("Key"));
    expect(page.name, "TestName");
    expect(page.restorationId, "restorationId");
  });

  group("getPageBuilderForCorrectType", () {
    testWidgets("For androind", (tester) async {
      final helper = AppRouterBuilderHelper();

      final key = GlobalKey<__TestStetefullWidgetState>();
      await tester.pumpWidget(
        MaterialApp(
          home: _TestStetefullWidget(key: key),
        ),
      );
      final page = helper.getPageBuilderForCorrectType(
        key.currentContext!,
      );
      expect(page, helper.pageBuilderForMaterialApp);
    });

    testWidgets("For iOS", (tester) async {
      final helper = AppRouterBuilderHelper();

      final key = GlobalKey<__TestStetefullWidgetState>();
      await tester.pumpWidget(
        CupertinoApp(
          home: _TestStetefullWidget(key: key),
        ),
      );
      final page = helper.getPageBuilderForCorrectType(
        key.currentContext!,
      );
      expect(page, helper.pageBuilderForCupertinoApp);
    });

    testWidgets("For other", (tester) async {
      final helper = AppRouterBuilderHelper();

      final key = GlobalKey<__TestStetefullWidgetState>();
      await tester.pumpWidget(
        _TestStetefullWidget(key: key),
      );
      final page = helper.getPageBuilderForCorrectType(
        key.currentContext!,
      );
      expect(page, helper.pageBuilderForWidgetApp);
    });
  });
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
