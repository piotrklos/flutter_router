import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef PageBuilderForAppType = Page<void> Function({
  required LocalKey key,
  required String name,
  required String restorationId,
  required Widget child,
});

class AppRouterBuilderHelper {
  @visibleForTesting
  bool isMaterialApp(Element elem) =>
      elem.findAncestorWidgetOfExactType<MaterialApp>() != null;

  @visibleForTesting
  bool isCupertinoApp(Element elem) =>
      elem.findAncestorWidgetOfExactType<CupertinoApp>() != null;

  @visibleForTesting
  CupertinoPage<void> pageBuilderForCupertinoApp({
    required LocalKey key,
    required String name,
    required String restorationId,
    required Widget child,
  }) {
    return CupertinoPage<void>(
      name: name,
      key: key,
      restorationId: restorationId,
      child: child,
    );
  }

  @visibleForTesting
  MaterialPage<void> pageBuilderForMaterialApp({
    required LocalKey key,
    required String name,
    required String restorationId,
    required Widget child,
  }) {
    return MaterialPage<void>(
      name: name,
      key: key,
      restorationId: restorationId,
      child: child,
    );
  }

  /// without any transitions
  @visibleForTesting
  Page<void> pageBuilderForWidgetApp({
    required LocalKey key,
    required String? name,
    required String restorationId,
    required Widget child,
  }) {
    return NoTransitionPage<void>(
      name: name,
      key: key,
      restorationId: restorationId,
      child: child,
    );
  }

  PageBuilderForAppType getPageBuilderForCorrectType(
    BuildContext context,
  ) {
    // can be null during testing
    final Element? elem = context is Element ? context : null;

    if (elem != null && isMaterialApp(elem)) {
      return pageBuilderForMaterialApp;
    } else if (elem != null && isCupertinoApp(elem)) {
      return pageBuilderForCupertinoApp;
    } else {
      return pageBuilderForWidgetApp;
    }
  }
}

@visibleForTesting
class NoTransitionPage<T> extends Page<T> {
  final Widget child;

  const NoTransitionPage({
    required this.child,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          arguments: arguments,
          key: key,
          name: name,
          restorationId: restorationId,
        );

  @override
  Route<T> createRoute(BuildContext context) => NoTransitionPageRoute<T>(this);
}

class NoTransitionPageRoute<T> extends PageRoute<T> {
  NoTransitionPageRoute(
    NoTransitionPage<T> page,
  ) : super(settings: page);

  NoTransitionPage<T> get _page => settings as NoTransitionPage<T>;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;
}
