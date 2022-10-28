import 'package:flutter/material.dart';

import 'inherited_router.dart';
import 'location.dart';

abstract class PBAppNavigator<C extends Object> {
  BackButtonDispatcher? get backButtonDispatcher;

  RouteInformationParser<C> get routeInformationParser;

  RouteInformationProvider? get routeInformationProvider;

  RouterDelegate<C> get routerDelegate;

  Future<void> init();

  /// completer work only when [backToParent] is true
  Future<T?> goNamed<T extends Object?>(
    String pageName, {
    Object? extra,
    bool backToParent = false,
  });

  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  });

  void pop<T extends Object?>([T? result]);

  PBRouteLocation? get currentLocation;

  static PBAppNavigator of(BuildContext context) {
    final InheritedPBAppRouter? inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedPBAppRouter>();
    return inherited!.appRouter;
  }
}
