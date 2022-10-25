import 'package:flutter/material.dart' show Icons, GlobalKey, NavigatorState;
import 'package:get_it/get_it.dart';

import '../../app_router/typedef.dart';
import '../../bloc/accounts/accounts_bloc.dart';
import '../../bloc/details/details_bloc.dart';
import '../../bloc/helper/helper_bloc.dart';
import '../../bloc/more/more_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../di/di.dart';
import '../../pages/home/accounts/accounts/accounts_page.dart';
import '../../pages/home/accounts/accounts_details_page.dart';
import '../../pages/home/accounts/relationship/relationship_page.dart';
import '../../service/user_service.dart';
import '../app_route.dart';

class AccountTabConfig {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  late final TabRouteItem _tabItem;
  TabRouteItem get tabItem => _tabItem;

  AccountTabConfig() {
    _init();
  }
  void _init() {
    _relationshipRoute.addRoute(_accountsRoute);
    _accountsRoute.addRoute(_accountsDetailsRoute);

    _tabItem = TabRouteItem(
      baseRoute: _relationshipRoute,
      iconData: Icons.people,
      name: "Accounts",
      navigatorKey: _navigatorKey,
      providers: const [
        AccountsCubit,
        DetailsCubit,
      ],
    );
  }

  final _relationshipRoute = PageRoute(
    name: "relationship",
    builder: (context, state) {
      return const RelationshipPage();
    },
    skip: (context, state) async {
      final userService = GetIt.instance.get<UserService>();
      final user = await userService.getUser();
      if (user.isIntrnal) {
        return null;
      }
      return SkipOption.goToChild;
    },
  );

  final _accountsRoute = PageRoute(
    name: "accounts",
    builder: (context, state) {
      return AccountsPage(
        familyName: state.extra != null ? (state.extra as String?) : null,
      );
    },
    providersBuilder: (cubitGetter) {
      return [
        getIt.get<SettingsCubit>(
          param1: cubitGetter<MoreCubit>(),
        ),
      ];
    },
  );

  final _accountsDetailsRoute = PageRoute(
    name: "accountsDetails",
    path: "details",
    builder: (context, state) {
      return const AccountsDetailsPage();
    },
    providersBuilder: (cubitGetter) {
      return [
        getIt.get<HelperCubit>(),
      ];
    },
  );
}
