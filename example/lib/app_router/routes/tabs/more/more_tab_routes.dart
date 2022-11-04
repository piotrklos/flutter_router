import 'package:get_it/get_it.dart';

import '../../../../bloc/helper/helper_bloc.dart';
import '../../../../bloc/more/more_bloc.dart';
import '../../../../bloc/settings/settings_bloc.dart';
import '../../../../pages/home/more/more_page.dart';
import '../../../../pages/home/more/notification/notification_page.dart';
import '../../../../pages/home/more/settings/helper/helper_page.dart';
import '../../../../pages/home/more/settings/settings_page.dart';
import '../../../interface/route.dart';

class MoreTabRoutes {
  PBPageRoute get baseRoute => _moreRoute;

  MoreTabRoutes() {
    _init();
  }

  void _init() {
    _moreRoute.addRoute(_notificationRoute);
    _moreRoute.addRoute(_settingsRoute);

    _settingsRoute.addRoute(_settingsHelperRoute);
  }

  final _moreRoute = PBPageRoute(
    name: MorePage.name,
    builder: (context, state) {
      return const MorePage();
    },
  );

  final _notificationRoute = PBPageRoute(
    name: NotificationPage.name,
    builder: (context, state) {
      return const NotificationPage();
    },
  );

  final _settingsRoute = PBPageRoute(
    name: SettingsPage.name,
    builder: (context, state) {
      return const SettingsPage();
    },
    providersBuilder: (cubitGetter) => [
      GetIt.instance.get<SettingsCubit>(
        param1: cubitGetter<MoreCubit>(),
      ),
    ],
  );

  final _settingsHelperRoute = PBPageRoute(
    name: HelperPage.name,
    builder: (context, state) {
      final text = state.extra is String ? state.extra as String : "";
      return HelperPage(
        initText: text,
      );
    },
    providersBuilder: (cubitGetter) => [
      GetIt.instance.get<HelperCubit>(),
    ],
  );
}
