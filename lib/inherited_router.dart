import 'package:flutter/widgets.dart';

import 'app_router_router.dart';

class InheritedAppRouter extends InheritedWidget {
  const InheritedAppRouter({
    required Widget child,
    required this.appRouter,
    Key? key,
  }) : super(
          child: child,
          key: key,
        );

  final AppRouter appRouter;

  @override
  bool updateShouldNotify(covariant InheritedAppRouter oldWidget) {
    return appRouter != oldWidget.appRouter;
  }
}
