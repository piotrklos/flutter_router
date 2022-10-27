import 'package:flutter/material.dart';

import 'inherited_router.dart';

abstract class PBAppRouter<C extends Object> {
  BackButtonDispatcher? get backButtonDispatcher;

  RouteInformationParser<C> get routeInformationParser;

  RouteInformationProvider? get routeInformationProvider;

  RouterDelegate<C> get routerDelegate;

  Future<void> init();

  Future<T?> go<T extends Object?>(
    String location, {
    Object? extra,
    bool backToParent = false,
  });

  /// completer work only when [backToParent] is true
  Future<T?> goNamed<T extends Object?>(
    String name, {
    Object? extra,
    bool backToParent = false,
  });

  Future<T?> push<T extends Object?>(
    String location, {
    Object? extra,
  });

  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  });

  void pop<T extends Object?>([T? result]);

  String? get currentLocation;

  static PBAppRouter of(BuildContext context) {
    final InheritedPBAppRouter? inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedPBAppRouter>();
    return inherited!.appRouter;
  }
}
