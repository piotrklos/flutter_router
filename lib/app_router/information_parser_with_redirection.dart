import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_router_cubit_provider.dart';
import 'route_finder.dart';
import 'router_information_state_object.dart';
import 'router_redirection.dart';

class AppRouteInformationParserWithRedirection
    extends RouteInformationParser<RouterPaths> {
  final RouteFinder routeFinder;
  final AppRouterCubitProvider cubitProvider;
  final AppRouterRedirector appRouterRedirector;

  AppRouteInformationParserWithRedirection(
    this.routeFinder,
    this.cubitProvider,
    this.appRouterRedirector,
  );

  @override
  Future<RouterPaths> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
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

    final FutureOr<RouterPaths> redirectorResult = appRouterRedirector.redirect(
      context,
      SynchronousFuture<RouterPaths>(routerPaths),
      routeFinder,
      extra: routeInformation.state,
    );
    if (redirectorResult is RouterPaths) {
      return _processRedirectorResult(redirectorResult, routeInformation);
    }

    return redirectorResult.then(
      (value) {
        return _processRedirectorResult(value, routeInformation);
      },
    );
  }

  Future<RouterPaths> _processRedirectorResult(
    RouterPaths routerPaths,
    RouteInformation routeInformation,
  ) {
    if (routerPaths.isEmpty) {
      return SynchronousFuture<RouterPaths>(
        RouterPaths(
          [
            FoundRoute.error(
              fullPath: routeInformation.location!,
              exception: Exception(
                'no routes for location: ${routeInformation.location}!',
              ),
            ),
          ],
        ),
      );
    }
    cubitProvider.setNewRouterPaths(routerPaths);

    return SynchronousFuture<RouterPaths>(routerPaths);
  }

  @override
  Future<RouterPaths> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    throw UnimplementedError(
      'use parseRouteInformationWithDependencies instead',
    );
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
