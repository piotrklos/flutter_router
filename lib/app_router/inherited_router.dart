import 'package:flutter/widgets.dart';

import 'app_router.dart';

class InheritedAppRouter extends InheritedWidget {
  const InheritedAppRouter({
    required super.child,
    required this.appRouter,
    super.key,
  });

  final AppRouter appRouter;

  @override
  bool updateShouldNotify(covariant InheritedAppRouter oldWidget) {
    return appRouter != oldWidget.appRouter;
  }
}
