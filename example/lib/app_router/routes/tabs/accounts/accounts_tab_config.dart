import 'package:flutter/material.dart';

import '../../../../bloc/accounts/accounts_bloc.dart';
import '../../../../bloc/details/details_bloc.dart';
import '../../../interface/route.dart';
import 'accounts_tab_routes.dart';

class AccountsTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  final AccountsTabRoutes _tabRoutes;
  late final PBTabRouteItem _tabItem;

  AccountsTabConfig() : _tabRoutes = AccountsTabRoutes() {
    _init();
  }

  PBTabRouteItem get tabItem => _tabItem;

  void _init() {
    _tabItem = PBTabRouteItem(
      baseRoute: _tabRoutes.baseRoute,
      iconData: Icons.people,
      name: "Accounts",
      navigatorKey: _navigatorKey,
      cubits: const [
        AccountsCubit,
        DetailsCubit,
      ],
    );
  }
}