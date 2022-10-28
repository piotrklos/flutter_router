import 'package:app_router/app_router.dart' as router;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../pages/home/tab_bar_page.dart';
import '../interface/app_router_bloc_provider.dart';
import '../interface/route.dart';
import '../interface/tab_bar_item_state.dart';
import 'mapper.dart';

extension IRouteExtension on IRoute {
  router.BaseAppRoute mapToBaseAppRoute() {
    if (this is PBPageRoute) {
      return (this as PBPageRoute).mapToBaseAppRoute();
    } else if (this is PBTabRoute) {
      return (this as PBTabRoute).mapToBaseAppRoute();
    }
    throw UnimplementedError("Not supported type!");
  }
}

extension PBPageRouteExtension on PBPageRoute {
  router.BaseAppRoute mapToBaseAppRoute() {
    return router.AppPageRoute(
      builder: (context, state) {
        return builder(
          context,
          state.mapToRouterPageState(),
        );
      },
      name: name,
      path: parent != null ? path : "/$path",
      routes: routes
          .map(
            (e) => e.mapToBaseAppRoute(),
          )
          .toList(),
      providersBuilder: (cubitGetter) =>
          providersBuilder?.call(<T extends PBAppRouterBlocProvider>() {
            return cubitGetter<T>();
          }) ??
          [],
      skip: skipper != null
          ? (state) {
              final skipOption = skipper!(state.mapToRouterPageState());
              if (skipOption is SkipOption?) {
                return skipOption?.mapToRouterSkipOption();
              } else {
                return skipOption.then((value) {
                  return value?.mapToRouterSkipOption();
                });
              }
            }
          : null,
      parentNavigatorKey: parentNavigatorKey,
    );
  }
}

extension PBTabRouteExtension on PBTabRoute {
  router.BaseAppRoute mapToBaseAppRoute() {
    return router.MultiShellRoute.stackedNavigationShell(
      routes: items
          .map(
            (e) => e.baseRoute.mapToBaseAppRoute(),
          )
          .toList(),
      stackItems: items
          .map(
            (e) => e._stackedNavigationItem(e.blocsGetter),
          )
          .toList(),
      scaffoldBuilder: (context, currentIndex, itemsState, child) {
        return TabBarPage(
          currentIndex: currentIndex,
          itemsState: itemsState.map((e) {
            return PBTabBarItemState(
              currentLocation: e.currentLocation.mapToPBRouteLocation(),
              rootRouteLocation:
                  e.item.rootRouteLocation.mapToPBRouteLocation(),
            );
          }).toList(),
          body: child,
          tabRouteItems: items,
        );
      },
      onPop: () {
        dispose();
      },
    );
  }
}

extension PBTabRouteItemExtension on PBTabRouteItem {
  router.StackedNavigationItem _stackedNavigationItem(
    ValueGetter<List<PBAppRouterBlocProvider>>? providers,
  ) {
    return router.StackedNavigationItem(
      rootRouteLocation: router.AppRouterLocation(
        path: baseRoute.fullpath,
        name: baseRoute.name,
      ),
      navigatorKey: navigatorKey,
      providers: () {
        return providers?.call().map((e) => e.blocProvider).toList() ?? [];
      },
    );
  }
}
