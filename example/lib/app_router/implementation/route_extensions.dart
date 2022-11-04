import 'package:app_router/app_router.dart' as router;
import 'package:flutter/material.dart';

import '../../pages/home/tab_bar_page.dart';
import '../interface/app_router_bloc_provider.dart';
import '../interface/route.dart';
import '../interface/tab_bar_item_state.dart';
import 'mapper.dart';

extension IRouteExtension on IRoute {
  router.BaseAppRoute mapToBaseAppRoute({
    bool withProviderBuilder = true,
  }) {
    if (this is PBPageRoute) {
      return (this as PBPageRoute).mapToBaseAppRoute(
        withProviderBuilder: withProviderBuilder,
      );
    } else if (this is PBTabRoute) {
      return (this as PBTabRoute).mapToBaseAppRoute(
        withProviderBuilder: withProviderBuilder,
      );
    }
    throw UnimplementedError("Not supported type!");
  }
}

extension PBPageRouteExtension on PBPageRoute {
  router.BaseAppRoute mapToBaseAppRoute({
    required bool withProviderBuilder,
  }) {
    return router.AppPageRoute(
      builder: (context, state) {
        return builder(
          context,
          state.mapToRouterPageState(),
        );
      },
      name: name,
      path: path,
      routes: routes
          .map(
            (e) => e.mapToBaseAppRoute(
              withProviderBuilder: withProviderBuilder,
            ),
          )
          .toList(),
      providersBuilder: (cubitGetter) {
        if (withProviderBuilder) {
          return providersBuilder?.call(<T extends PBAppRouterBlocProvider>() {
                return cubitGetter<T>();
              }) ??
              [];
        }
        return [];
      },
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
  router.BaseAppRoute mapToBaseAppRoute({
    required bool withProviderBuilder,
  }) {
    return router.MultiShellRoute.stackedNavigationShell(
      routes: items
          .map(
            (e) => e.baseRoute.mapToBaseAppRoute(
              withProviderBuilder: withProviderBuilder,
            ),
          )
          .toList(),
      stackItems: items
          .map(
            (e) => e._stackedNavigationItem(
              providers: e.blocsGetter,
              withProviderBuilder: withProviderBuilder,
            ),
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
  router.StackedNavigationItem _stackedNavigationItem({
    required ValueGetter<List<PBAppRouterBlocProvider>>? providers,
    required bool withProviderBuilder,
  }) {
    return router.StackedNavigationItem(
      rootRouteLocation: router.AppRouterLocation(
        path: baseRoute.fullpath,
        name: baseRoute.name,
      ),
      navigatorKey: navigatorKey,
      providers: () {
        if (withProviderBuilder) {
          return providers?.call() ?? [];
        }
        return <router.AppRouterBlocProvider>[];
      }(),
    );
  }
}
