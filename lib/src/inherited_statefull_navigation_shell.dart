import 'package:flutter/widgets.dart';

import 'page_state.dart';

class InheritedStatefulNavigationShell extends InheritedWidget {
  const InheritedStatefulNavigationShell({
    required Widget child,
    required this.routeState,
    Key? key,
  }) : super(child: child, key: key);

  final StatefulShellRouteState routeState;

  @override
  bool updateShouldNotify(
    covariant InheritedStatefulNavigationShell oldWidget,
  ) {
    return routeState != oldWidget.routeState;
  }
}
