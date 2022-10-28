import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'inherited_router.dart';
import 'location.dart';

abstract class PBAppNavigator {
  Future<void> init({
    String? initialLocationName,
    List<NavigatorObserver> observers = const [],
  });

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

  Widget getAppWidget({
    ThemeData? materialThemeData,
    CupertinoThemeData? cupertinoThemeData,
    List<Locale> supportedLocales = const <Locale>[Locale('en', 'US')],
    Locale? locale,
    List<LocalizationsDelegate>? localizationsDelegates,
    String title = '',
    bool useInheritedMediaQuery = false,
  });
}
