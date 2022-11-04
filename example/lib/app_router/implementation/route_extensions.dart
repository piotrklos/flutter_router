import 'package:app_router/app_router.dart' as router;
import 'package:example/app_router/interface/tab_bar_state.dart';

import '../../pages/home/tab_bar_page.dart';
import '../interface/app_router_bloc_provider.dart';
import '../interface/route.dart';
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
    return router.StatefulShellRoute(
      preloadBranches: false,
      branches: items
          .map(
            (e) => e._mapToBranche(
              withProviderBuilder: withProviderBuilder,
            ),
          )
          .toList(),
      builder: (ctx, __, child) {
        return TabBarPage(
          child: child,
          items: items,
          state: () {
            final state = router.StatefulShellRoute.of(ctx);
            return TabBarState(
              currentIndex: state.currentIndex,
              changeTab: (index, resetLocatiom) {
                state.goToBranch(index, resetLocation: resetLocatiom);
              },
            );
          }(),
        );
      },
      onPop: () {
        dispose();
      },
    );
  }
}

extension PBTabRouteItemExtension on PBTabRouteItem {
  router.ShellRouteBranch _mapToBranche({
    required bool withProviderBuilder,
  }) {
    return router.ShellRouteBranch(
      navigatorKey: navigatorKey,
      restorationScopeId: restorationScopeId,
      defaultLocation: router.AppRouterLocation(
        name: baseRoute.name,
        path: baseRoute.fullpath,
      ),
      rootRoute: baseRoute.mapToBaseAppRoute(
        withProviderBuilder: withProviderBuilder,
      ),
      providersBuilder: () {
        if (withProviderBuilder) {
          return blocsGetter?.call() ?? [];
        }
        return <router.AppRouterBlocProvider>[];
      },
    );
  }
}
