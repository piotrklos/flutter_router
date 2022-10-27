import 'package:get_it/get_it.dart';

import '../../../interface/route.dart';
import '../../../../bloc/helper/helper_bloc.dart';
import '../../../../bloc/more/more_bloc.dart';
import '../../../../bloc/settings/settings_bloc.dart';
import '../../../../pages/home/accounts/accounts/accounts_page.dart';
import '../../../../pages/home/accounts/accounts_details_page.dart';
import '../../../../pages/home/accounts/relationship/relationship_page.dart';
import '../../../../service/user_service.dart';

class AccountsTabRoutes {
  IRoute get baseRoute => _relationshipRoute;

  AccountsTabRoutes() {
    _init();
  }

  void _init() {
    _accountsRoute.addRoute(_accountsDetailsRoute);
    _relationshipRoute.addRoute(_accountsRoute);
  }

  final _relationshipRoute = PBPageRoute(
    name: RelationshipPage.name,
    builder: (context, state) {
      return const RelationshipPage();
    },
    skipper: (state) async {
      final userService = GetIt.instance.get<UserService>();
      final user = await userService.getUser();
      if (user.isIntrnal) {
        return null;
      }
      return SkipOption.goToChild;
    },
  );

  final _accountsRoute = PBPageRoute(
    name: AccountsPage.name,
    builder: (context, state) {
      return AccountsPage(
        familyName: state.extra != null ? (state.extra as String?) : null,
      );
    },
  );

  final _accountsDetailsRoute = PBPageRoute(
    name: AccountsDetailsPage.name,
    path: "details",
    builder: (context, state) {
      return const AccountsDetailsPage();
    },
  );
}
