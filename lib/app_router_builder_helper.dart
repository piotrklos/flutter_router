import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef PageBuilderForAppType = Page<void> Function({
  required LocalKey key,
  required String? name,
  required String restorationId,
  required Widget child,
});

class AppRouterBuilderHelper {
  bool _isMaterialApp(Element elem) =>
      elem.findAncestorWidgetOfExactType<MaterialApp>() != null;

  bool _isCupertinoApp(Element elem) =>
      elem.findAncestorWidgetOfExactType<CupertinoApp>() != null;

  CupertinoPage<void> _pageBuilderForCupertinoApp({
    required LocalKey key,
    required String? name,
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

  MaterialPage<void> _pageBuilderForMaterialApp({
    required LocalKey key,
    required String? name,
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
  Page<void> _pageBuilderForWidgetApp({
    required LocalKey key,
    required String? name,
    required String restorationId,
    required Widget child,
  }) {
    return _NoTransitionPage<void>(
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

    if (elem != null && _isMaterialApp(elem)) {
      return _pageBuilderForMaterialApp;
    } else if (elem != null && _isCupertinoApp(elem)) {
      return _pageBuilderForCupertinoApp;
    } else {
      return _pageBuilderForWidgetApp;
    }
  }
}

class _NoTransitionPage<T> extends Page<T> {
  final Widget child;

  const _NoTransitionPage({
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
  Route<T> createRoute(BuildContext context) => _NoTransitionPageRoute<T>(this);
}

class _NoTransitionPageRoute<T> extends PageRoute<T> {
  _NoTransitionPageRoute(
    _NoTransitionPage<T> page,
  ) : super(settings: page);

  _NoTransitionPage<T> get _page => settings as _NoTransitionPage<T>;

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
