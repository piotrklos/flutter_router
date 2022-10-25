import 'dart:async';

import 'route_finder.dart';
import 'package:flutter/material.dart';

import '../bloc/base_app_bloc.dart';
import 'app_router_page_state.dart';
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
  Navigator navigator,
);

typedef StackedNavigationScaffoldBuilder = Widget Function(
  BuildContext context,
  int currentIndex,
  List<StackedNavigationItemState> itemsState,
  Widget child,
);

typedef AppRouteProvidersBuilder = T?
    Function<T extends AppRouterBlocProvider>();

typedef AppRouterRedirect = FutureOr<String?> Function(
  BuildContext context,
  AppRouterPageState state,
);

typedef AppRouterSkip = FutureOr<SkipOption?> Function(
  BuildContext context,
  AppRouterPageState state,
);

typedef AppRouteRedirectorFunction = FutureOr<RouterPaths> Function(
  BuildContext,
  FutureOr<RouterPaths>,
  RouteFinder, {
  List<RouterPaths>? redirectHistory,
  Object? extra,
});

enum SkipOption {
  goToParent,
  goToChild,
}