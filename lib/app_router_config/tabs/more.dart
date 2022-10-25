import 'package:flutter/material.dart' show Icons, GlobalKey, NavigatorState;

import '../../bloc/helper/helper_bloc.dart';
import '../../bloc/more/more_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../di/di.dart';
import '../../pages/home/more/more_page.dart';
import '../../pages/home/more/notification/notification_page.dart';
import '../../pages/home/more/settings/helper/helper_page.dart';
import '../../pages/home/more/settings/settings_page.dart';
import '../app_route.dart';

class MoreTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  late final TabRouteItem _tabItem;
  TabRouteItem get tabItem => _tabItem;

  MoreTabConfig() {
    _init();
  }

  void _init() {
    _settingsRoute.addRoute(_settingsHelperRoute);
    _moreRoute.addRoute(_notificationRoute);
    _moreRoute.addRoute(_settingsRoute);

    _tabItem = TabRouteItem(
      baseRoute: _moreRoute,
      iconData: Icons.more_horiz,
      name: "More",
      navigatorKey: _navigatorKey,
    );
  }

  final _moreRoute = PageRoute(
    name: "more",
    builder: (context, state) {
      return const MorePage();
    },
    providersBuilder: (cubitGetter) => [
      getIt.get<MoreCubit>(),
    ],
  );

  final _notificationRoute = PageRoute(
    name: "notification",
    builder: (context, state) {
      return const NotificationPage();
    },
  );

  final _settingsRoute = PageRoute(
    name: "settings",
    builder: (context, state) {
      return const SettingsPage();
    },
    providersBuilder: (cubitGetter) => [
      getIt.get<SettingsCubit>(
        param1: cubitGetter<MoreCubit>(),
      ),
    ],
  );

  final _settingsHelperRoute = PageRoute(
    name: "helper",
    builder: (context, state) {
      final text = state.extra is String ? state.extra as String : "";
      return HelperPage(
        initText: text,
      );
    },
    providersBuilder: (cubitGetter) => [
      getIt.get<HelperCubit>(),
    ],
  );
}
