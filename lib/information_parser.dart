import 'dart:async';

import 'router_exception.dart';
import 'router_skipper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_router_cubit_provider.dart';
import 'route_finder.dart';
import 'router_information_state_object.dart';

class AppRouteInformationParser extends RouteInformationParser<RouterPaths> {
  final RouteFinder routeFinder;
  final AppRouterCubitProvider cubitProvider;
  final AppRouterSkipper appRouterSkipper;

  AppRouteInformationParser(
    this.routeFinder,
    this.cubitProvider,
    this.appRouterSkipper,
  );

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

    try {
      final skipResult = appRouterSkipper.skip(
        SynchronousFuture<RouterPaths>(routerPaths),
        routeFinder,
      );
      if (skipResult is RouterPaths) {
        return _processSkipResult(skipResult, routeInformation);
      }

      return skipResult.then(
        (value) {
          return _processSkipResult(value, routeInformation);
        },
        onError: (error, stackTrace) {
          AppRouterException? routerException;
          if (error is AppRouterException) {
            routerException = error;
          }
          return _processSkipError(routeInformation,
              exception: routerException);
        },
      );
    } catch (error) {
      AppRouterException? routerException;
      if (error is AppRouterException) {
        routerException = error;
      }
      return _processSkipError(routeInformation, exception: routerException);
    }
  }

  RouterPaths _processSkipError(
    RouteInformation routeInformation, {
    AppRouterException? exception,
  }) {
    return RouterPaths(
      [
        FoundRoute.error(
          fullPath: routeInformation.location!,
          exception: exception ??
              Exception(
                'no routes for location: ${routeInformation.location}!',
              ),
        ),
      ],
    );
  }

  RouterPaths _processSkipResult(
    RouterPaths routerPaths,
    RouteInformation routeInformation,
  ) {
    if (routerPaths.isEmpty) {
      return _processSkipError(routeInformation);
    }
    cubitProvider.setNewRouterPaths(routerPaths);

    return routerPaths;
  }

  @override
  RouteInformation restoreRouteInformation(RouterPaths configuration) {
    cubitProvider.restoreRouteInformation(configuration);
    return RouteInformation(
      location: configuration.location?.path,
      state: configuration.extra,
    );
  }
}
