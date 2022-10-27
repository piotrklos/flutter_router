import 'package:example/bloc/more/more_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../interface/route.dart';
import 'more_tab_routes.dart';

class MoreTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  final MoreTabRoutes _tabRoutes;
  late final PBTabRouteItem _tabItem;

  MoreTabConfig() : _tabRoutes = MoreTabRoutes() {
    _init();
  }

  PBTabRouteItem get tabItem => _tabItem;

  void _init() {
    _tabItem = PBTabRouteItem(
      baseRoute: _tabRoutes.baseRoute,
      iconData: Icons.more_horiz,
      name: "More",
      navigatorKey: _navigatorKey,
      blocsGetter: () => [
        GetIt.instance.get<MoreCubit>(),
      ],
      onDispose: onDispose,
    );
  }

  void onDispose() {
    GetIt.instance.resetLazySingleton<MoreCubit>();
  }
}
