import 'dart:async';

import 'router_exception.dart';
import 'router_skipper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'cubit_provider.dart';
import 'route_finder.dart';
import 'router_information_state_object.dart';

class AppRouteInformationParser extends RouteInformationParser<RouterPaths> {
  final RouteFinder routeFinder;
  final AppRouterCubitProvider cubitProvider;
  final AppRouterSkipper appRouterSkipper;
  static const int maxSkipIteration = 5;

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
    return _proccessSkip(routerPaths, routeInformation);
  }

  FutureOr<RouterPaths> _proccessSkip(
    RouterPaths routerPaths,
    RouteInformation routeInformation, {
    int iterationCount = 0,
  }) {
    if (iterationCount >= maxSkipIteration) {
      return _processSkipError(
        routeInformation,
        exception: AppRouterException(
          "Too many skip detected!",
        ),
      );
    }
    try {
      final skipResult = appRouterSkipper.skip(
        SynchronousFuture<RouterPaths>(routerPaths.copy()),
        routeFinder,
      );
      if (skipResult is RouterPaths) {
        return _processSkipResult(
          routerPaths,
          skipResult,
          routeInformation,
          iterationCount: iterationCount,
        );
      }

      return skipResult.then(
        (value) {
          return _processSkipResult(
            routerPaths,
            value,
            routeInformation,
            iterationCount: iterationCount,
          );
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

  FutureOr<RouterPaths> _processSkipResult(
    RouterPaths routerPaths,
    RouterPaths skipRouterPaths,
    RouteInformation routeInformation, {
    required int iterationCount,
  }) {
    if (routerPaths != skipRouterPaths) {
      return _proccessSkip(
        skipRouterPaths,
        routeInformation,
        iterationCount: iterationCount + 1,
      );
    }
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
