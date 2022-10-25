import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../app_router/app_router.dart';
import '../pages/shared/error_page.dart';
import '../service/user_service.dart';
import 'app_route.dart';
import 'routes.dart';
import 'tabs/accounts.dart';
import 'tabs/documents.dart';
import 'tabs/insights.dart';
import 'tabs/messages.dart';
import 'tabs/more.dart';

@Injectable()
class AppRouterConfig {
  final UserService userService;
  late final AppRouter appRouter;
  static final globalNavigationKey = GlobalKey<NavigatorState>();

  AppRouterConfig(this.userService);

  void init() {
    appRouter = AppRouter(
      navigatorKey: globalNavigationKey,
      routes: [
        PageRoutes.startRoute,
        PageRoutes.sharedRoute,
        TabRoute(
          items: [
            AccountTabConfig().tabItem,
            DocumentsTabConfig().tabItem,
            MessagesTabConfig().tabItem,
            InsightsTabConfig().tabItem,
            MoreTabConfig().tabItem,
          ],
        ),
      ]
          .map(
            (e) => e.mapToBaseAppRoute(),
          )
          .toList(),
      errorBuilder: (ctx, state) {
        return ErrorPage(
          message: state.exception.toString(),
        );
      },
    );
  }
}
