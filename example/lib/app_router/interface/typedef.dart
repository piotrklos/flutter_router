import 'dart:async';

import 'package:example/app_router/interface/app_router_bloc_provider.dart';
import 'package:flutter/material.dart';

import 'router_page_state.dart';
import 'skipper.dart';

typedef PBCubitGetter = T? Function<T extends PBAppRouterBlocProvider>();

typedef PBAppRouteWidgetBuilder = Widget Function(
  BuildContext context,
  PBAppRouterPageState state,
);

typedef PBAppRouteSkipper = FutureOr<SkipOption?> Function(
  PBAppRouterPageState state,
);
