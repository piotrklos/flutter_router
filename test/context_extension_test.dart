import 'package:app_router/src/app_router.dart';
import 'package:app_router/src/context_extension.dart';
import 'package:app_router/src/inherited_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helper/mock_app_router.dart';

void main() {
  late final AppRouter appRouter;

  setUpAll(() {
    appRouter = MockAppRouter();
  });

  group("go", () {
    testWidgets("go without extra arguments", (tester) async {
      when(() => appRouter.go("test")).thenAnswer((_) => Future.value());

      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      key.currentContext!.go("test");

      verify(() => appRouter.go("test")).called(1);
    });

    testWidgets("go with extra arguments", (tester) async {
      const extra = _TestObject();
      const resultObject = _TestObject(message: "result");

      when(
        () => appRouter.go("test", backToParent: true, extra: extra),
      ).thenAnswer((_) => Future.value(resultObject));
      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      final result = await key.currentContext!.go(
        "test",
        backToParent: true,
        extra: extra,
      );

      verify(
        () => appRouter.go("test", backToParent: true, extra: extra),
      ).called(1);
      expect(result, resultObject);
    });
  });

  group("goNamed", () {
    testWidgets("goNamed without extra arguments", (tester) async {
      when(() => appRouter.goNamed("test")).thenAnswer((_) => Future.value());

      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      key.currentContext!.goNamed("test");

      verify(() => appRouter.goNamed("test")).called(1);
    });

    testWidgets("goNamed with extra arguments", (tester) async {
      const extra = _TestObject();
      const resultObject = _TestObject(message: "result");

      when(
        () => appRouter.goNamed("test", backToParent: true, extra: extra),
      ).thenAnswer((_) => Future.value(resultObject));
      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      final result = await key.currentContext!.goNamed(
        "test",
        backToParent: true,
        extra: extra,
      );

      verify(
        () => appRouter.goNamed("test", backToParent: true, extra: extra),
      ).called(1);
      expect(result, resultObject);
    });
  });

  group("push", () {
    testWidgets("push without extra arguments", (tester) async {
      when(() => appRouter.push("test")).thenAnswer((_) => Future.value());

      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      key.currentContext!.push("test");

      verify(() => appRouter.push("test")).called(1);
    });

    testWidgets("push with extra arguments", (tester) async {
      const extra = _TestObject();
      const resultObject = _TestObject(message: "result");

      when(
        () => appRouter.push("test", extra: extra),
      ).thenAnswer((_) => Future.value(resultObject));
      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      final result = await key.currentContext!.push(
        "test",
        extra: extra,
      );

      verify(
        () => appRouter.push("test", extra: extra),
      ).called(1);
      expect(result, resultObject);
    });
  });

  group("pushNamed", () {
    testWidgets("pushNamed without extra arguments", (tester) async {
      when(() => appRouter.pushNamed("test")).thenAnswer((_) => Future.value());

      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      key.currentContext!.pushNamed("test");

      verify(() => appRouter.pushNamed("test")).called(1);
    });

    testWidgets("pushNamed with extra arguments", (tester) async {
      const extra = _TestObject();
      const resultObject = _TestObject(message: "result");

      when(
        () => appRouter.pushNamed("test", extra: extra),
      ).thenAnswer((_) => Future.value(resultObject));
      final key = GlobalKey();
      await tester.pumpWidget(InheritedAppRouter(
        appRouter: appRouter,
        child: SizedBox.shrink(key: key),
      ));

      final result = await key.currentContext!.pushNamed(
        "test",
        extra: extra,
      );

      verify(
        () => appRouter.pushNamed("test", extra: extra),
      ).called(1);
      expect(result, resultObject);
    });
  });

  testWidgets("canPop", (tester) async {
    when(() => appRouter.canPop()).thenAnswer((_) => true);
    final key = GlobalKey();
    await tester.pumpWidget(InheritedAppRouter(
      appRouter: appRouter,
      child: SizedBox.shrink(key: key),
    ));

    final result = key.currentContext!.canPop();

    verify(() => appRouter.canPop()).called(1);
    expect(result, true);
  });

  testWidgets("pop", (tester) async {
    when(() => appRouter.pop()).thenAnswer((_) => true);
    final key = GlobalKey();
    await tester.pumpWidget(InheritedAppRouter(
      appRouter: appRouter,
      child: SizedBox.shrink(key: key),
    ));

    key.currentContext!.pop();

    verify(() => appRouter.pop()).called(1);
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
