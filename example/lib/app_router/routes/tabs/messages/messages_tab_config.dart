import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../bloc/details/details_bloc.dart';
import '../../../../bloc/messages/messages_bloc.dart';
import '../../../interface/route.dart';
import 'messages_tab_routes.dart';

class MessagesTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  final MessagesTabRoutes _tabRoutes;
  late final PBTabRouteItem _tabItem;

  MessagesTabConfig() : _tabRoutes = MessagesTabRoutes() {
    _init();
  }

  PBTabRouteItem get tabItem => _tabItem;

  void _init() {
    _tabItem = PBTabRouteItem(
      baseRoute: _tabRoutes.baseRoute,
      iconData: Icons.message,
      name: "Messages",
      navigatorKey: _navigatorKey,
      blocsGetter: () => [
        GetIt.instance.get<MessagesCubit>(),
        GetIt.instance.get<DetailsCubit>(),
      ],
      onDispose: () {
        onDispose();
      },
    );
  }

  void onDispose() {
    GetIt.instance.resetLazySingleton<MessagesCubit>(
      instance: GetIt.instance.get<MessagesCubit>(),
    );
    GetIt.instance.resetLazySingleton<DetailsCubit>(
      instance: GetIt.instance.get<DetailsCubit>(),
    );
  }
}
