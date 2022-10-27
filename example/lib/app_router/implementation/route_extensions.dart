import 'package:app_router/app_router.dart' as router;

import '../../pages/home/tab_bar_page.dart';
import '../interface/app_router_bloc_provider.dart';
import '../interface/route.dart';
import '../interface/tab_bar_item_state.dart';
import 'mapper.dart';
import 'route_impl.dart';

extension IRouteExtension on IRoute {
  router.BaseAppRoute mapToBaseAppRoute() {
    if (this is PBPageRoute) {
      return (this as PBPageRoute).mapToBaseAppRoute();
    } else if (this is PBTabRoute) {
      if (this is PBTabRouteWithDependencie) {
        return (this as PBTabRouteWithDependencie).mapToBaseAppRoute();
      }
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
      providersBuilder: (cubitGetter) {
        return providersBuilder?.call(<T extends PBAppRouterBlocProvider>() {
              return cubitGetter<T>();
            }) ??
            [];
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

extension PBTabRouteExtension on PBTabRouteWithDependencie {
  router.BaseAppRoute mapToBaseAppRoute() {
    return router.MultiShellRoute.stackedNavigationShell(
      routes: items
          .map(
            (e) => e.baseRoute.mapToBaseAppRoute(),
          )
          .toList(),
      stackItems: items
          .map(
            (e) => e._stackedNavigationItem(_dependenciesForTabRouteItem(e)),
          )
          .toList(),
      scaffoldBuilder: (context, currentIndex, itemsState, child) {
        return TabBarPage(
          currentIndex: currentIndex,
          itemsState: itemsState.map((e) {
            return PBTabBarItemState(
              currentLocation: e.currentLocation,
              rootRoutePath: e.item.rootRoutePath,
            );
          }).toList(),
          body: child,
          tabRouteItems: items,
        );
      },
    );
  }

  List<PBAppRouterBlocProvider> _dependenciesForTabRouteItem(
    PBTabRouteItem item,
  ) {
    List<PBAppRouterBlocProvider> dependencies = [];

    final dependenciesNames = dependenciesMap[item];
    dependenciesNames?.forEach((dependency) {
      final provider = dependenciesProvider[dependency];
      if (provider != null) {
        dependencies.add(provider);
      }
    });

    return dependencies;
  }
}

extension PBTabRouteItemExtension on PBTabRouteItem {
  router.StackedNavigationItem _stackedNavigationItem(
    List<PBAppRouterBlocProvider> providers,
  ) {
    return router.StackedNavigationItem(
      rootRoutePath: baseRoute.fullpath,
      navigatorKey: navigatorKey,
      providers: providers.map((e) => e.blocProvider).toList(),
    );
  }
}
