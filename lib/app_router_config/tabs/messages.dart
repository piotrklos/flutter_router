import 'package:flutter/material.dart' show Icons, GlobalKey, NavigatorState;

import '../../bloc/details/details_bloc.dart';
import '../../bloc/messages/messages_bloc.dart';
import '../../pages/home/messages/messages_details_page.dart';
import '../../pages/home/messages/messages_page.dart';
import '../app_route.dart';

class MessagesTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  late final TabRouteItem _tabItem;
  TabRouteItem get tabItem => _tabItem;

  MessagesTabConfig() {
    _init();
  }

  void _init() {
    _messagesRoute.addRoute(_messagesDetailsRoute);

    _tabItem = TabRouteItem(
      baseRoute: _messagesRoute,
      iconData: Icons.message,
      name: "Messages",
      navigatorKey: _navigatorKey,
      providers: const [
        MessagesCubit,
        DetailsCubit,
      ],
    );
  }

  final _messagesRoute = PageRoute(
    name: "messages",
    builder: (context, state) {
      return const MessagesPage();
    },
  );

  final _messagesDetailsRoute = PageRoute(
    name: "messagesDetails",
    path: "details",
    builder: (context, state) {
      return const MessagesDetailsPage();
    },
  );
}
