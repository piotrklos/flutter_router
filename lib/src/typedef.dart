import 'dart:async';

import 'bloc_provider.dart';
import 'package:flutter/material.dart';

import 'page_state.dart';
import 'stacked_navigation_shell.dart';

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

typedef StackedNavigationScaffoldBuilder = Widget Function(
  BuildContext context,
  int currentIndex,
  List<StackedNavigationItemState> itemsState,
  Widget child,
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
