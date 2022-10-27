import 'package:flutter/widgets.dart';

import 'router.dart';

class InheritedPBAppRouter extends InheritedWidget {
  const InheritedPBAppRouter({
    required Widget child,
    required this.appRouter,
    Key? key,
  }) : super(
          child: child,
          key: key,
        );

  final PBAppRouter appRouter;

  @override
  bool updateShouldNotify(covariant InheritedPBAppRouter oldWidget) {
    return appRouter != oldWidget.appRouter;
  }
}
