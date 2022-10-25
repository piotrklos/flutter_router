import 'package:flutter/material.dart';

import 'app_router_cubit_provider.dart';
import 'route_finder.dart';
import 'router_information_state_object.dart';

class AppRouteInformationParser extends RouteInformationParser<RouterPaths> {
  final RouteFinder routeFinder;
  final AppRouterCubitProvider cubitProvider;

  AppRouteInformationParser(
    this.routeFinder,
    this.cubitProvider,
  );

  @override
  Future<RouterPaths> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) async {
    return parseRouteInformation(routeInformation);
  }

  @override
  Future<RouterPaths> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    late final RouterPaths routerPaths;
    try {
      RouterInformationStateObject? stateObject;
      if (routeInformation.state is RouterInformationStateObject) {
        stateObject = routeInformation.state as RouterInformationStateObject;
      }

      routerPaths = routeFinder.findForPath(
        routeInformation.location!,
        extra: stateObject != null ? stateObject.extra : routeInformation.state,
        shouldBackToParent: stateObject?.backToParent ?? false,
        parentStack: stateObject?.parentStack,
        completer: stateObject?.completer,
      );
    } catch (_) {
      routerPaths = RouterPaths.empty();
    }
    cubitProvider.setNewRouterPaths(routerPaths);
    if (routerPaths.isEmpty) {
      routerPaths.addNew(
        FoundRoute.error(
          fullPath: routeInformation.location!,
          exception: Exception(
            'no routes for location: ${routeInformation.location}!',
          ),
        ),
      );
    }
    return routerPaths;
  }

  @override
  RouteInformation restoreRouteInformation(RouterPaths configuration) {
    cubitProvider.restoreRouteInformation(configuration);
    return RouteInformation(
      location: configuration.location,
      state: configuration.extra,
    );
  }
}
