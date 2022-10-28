import 'package:app_router/app_router.dart' as router;

import '../interface/location.dart';
import '../interface/router_page_state.dart';
import '../interface/skipper.dart';

extension AppRouterPageStateMapper on router.AppRouterPageState {
  PBAppRouterPageState mapToRouterPageState() {
    return PBAppRouterPageState(
      fullpath: fullpath,
      exception: exception,
      extra: extra,
      name: name,
    );
  }
}

extension SkipOptionExtension on SkipOption {
  router.SkipOption mapToRouterSkipOption() {
    switch (this) {
      case SkipOption.goToChild:
        return router.SkipOption.goToChild;

      case SkipOption.goToParent:
        return router.SkipOption.goToParent;
    }
  }
}

extension AppRouterLocation on router.AppRouterLocation {
  PBRouteLocation mapToPBRouteLocation() {
    return PBRouteLocation(
      name: name,
      path: path,
    );
  }
}
