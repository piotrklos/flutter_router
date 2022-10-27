import 'package:example/app_router/interface/route.dart';

import 'accounts/accounts_tab_config.dart';
import 'documents/documents_tab_config.dart';
import 'insights/insights_tab_config.dart';
import 'messages/messages_tab_config.dart';
import 'more/more_tab_config.dart';

class TabConfig {
  late final PBTabRoute _tabRoute;

  TabConfig() {
    _init();
  }

  void _init() {
    _tabRoute = PBTabRoute(
      items: [
        AccountsTabConfig().tabItem,
        DocumentsTabConfig().tabItem,
        MessagesTabConfig().tabItem,
        InsightsTabConfig().tabItem,
        MoreTabConfig().tabItem,
      ],
    );
  }

  PBTabRoute get tabRoute => _tabRoute;
}
