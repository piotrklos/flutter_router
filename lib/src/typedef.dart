import 'dart:async';

import 'bloc_provider.dart';
import 'package:flutter/material.dart';

import 'page_state.dart';

typedef AppRouterWidgetBuilder = Widget Function(
  BuildContext context,
  AppRouterPageState state,
);

typedef ShellRouteBuilder = Widget Function(
  BuildContext context,
  AppRouterPageState state,
  Widget child,
);

typedef AppRouterBuilderWithNavigator = Widget Function(
  BuildContext context,
  AppRouterPageState state,
  Widget navigator,
);

typedef ShellRouteBranchNavigatorBuilder = Navigator? Function(
  BuildContext context,
  StatefulShellRouteState routeState,
  int branchIndex,
);

typedef AppRouteProvidersBuilder = T?
    Function<T extends AppRouterBlocProvider>();

typedef AppRouterSkip = FutureOr<SkipOption?> Function(
  AppRouterPageState state,
);

enum SkipOption {
  goToParent,
  goToChild,
}
