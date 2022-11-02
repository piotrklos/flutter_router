import 'package:flutter/material.dart';

import 'app_router_router.dart';

extension AppRouterExtension on BuildContext {
  Future<T?> go<T extends Object?>(
    String location, {
    Object? extra,
    bool backToParent = false,
  }) {
    return AppRouter.of(this).go(
      location,
      extra: extra,
      backToParent: backToParent,
    );
  }

  Future<T?> goNamed<T extends Object?>(
    String name, {
    Object? extra,
    bool backToParent = false,
  }) {
    return AppRouter.of(this).goNamed(
      name,
      extra: extra,
      backToParent: backToParent,
    );
  }

  Future<T?> push<T extends Object?>(
    String location, {
    Object? extra,
  }) {
    return AppRouter.of(this).push<T>(location, extra: extra);
  }

  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  }) {
    return AppRouter.of(this).pushNamed(name, extra: extra);
  }

  bool canPop() {
    return AppRouter.of(this).canPop();
  }

  void pop<T extends Object?>([T? result]) {
    AppRouter.of(this).pop(result);
  }
}
