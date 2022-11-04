import 'dart:async';

import 'package:flutter/foundation.dart';

import 'page_state.dart';
import 'configuration.dart';
import 'route.dart';
import 'route_finder.dart';
import 'router_exception.dart';
import 'typedef.dart';

class AppRouterSkipper {
  final AppRouterConfiguration configuration;

  AppRouterSkipper(this.configuration);

  FutureOr<RouterPaths> skip(
    FutureOr<RouterPaths> routerPathsFuture,
    RouteFinder routeFinder,
  ) {
    if (routerPathsFuture is RouterPaths) {
      return processSkip(
        routerPathsFuture,
        routeFinder: routeFinder,
        index: routerPathsFuture.length - 1,
      );
    }
    return routerPathsFuture.then<RouterPaths>(
      (value) {
        return processSkip(
          value,
          routeFinder: routeFinder,
          index: value.length - 1,
        );
      },
    );
  }

  @visibleForTesting
  FutureOr<RouterPaths> processSkip(
    RouterPaths routerPaths, {
    required RouteFinder routeFinder,
    required int index,
  }) {
    if (index < 0) {
      return routerPaths;
    }
    if (routerPaths.isEmpty) {
      return routerPaths;
    }

    final FutureOr<SkipOption?> skipResult = getSkipper(
      routerPaths,
      index,
    );

    if (skipResult is SkipOption?) {
      return _processRouteLevelSkipper(
        skipResult,
        routeFinder: routeFinder,
        routerPaths: routerPaths,
        index: index,
      );
    }
    return skipResult.then<RouterPaths>(
      (value) {
        return _processRouteLevelSkipper(
          value,
          routeFinder: routeFinder,
          routerPaths: routerPaths,
          index: index,
        );
      },
    );
  }

  FutureOr<RouterPaths> _processRouteLevelSkipper(
    SkipOption? skipOption, {
    required RouterPaths routerPaths,
    required RouteFinder routeFinder,
    required int index,
  }) {
    if (skipOption != null) {
      final RouterPaths newRouterPaths = routeFinder.proccessSkipToPaths(
        skipOption: skipOption,
        routerPaths: routerPaths,
        index: index,
      );

      return processSkip(
        newRouterPaths,
        index: index - 1,
        routeFinder: routeFinder,
      );
    }
    return processSkip(
      routerPaths,
      index: index - 1,
      routeFinder: routeFinder,
    );
  }

  @visibleForTesting
  FutureOr<SkipOption?> getSkipper(
    RouterPaths routerPaths,
    int index,
  ) {
    FutureOr<SkipOption?>? routeSkipResult;
    final foundRoute = routerPaths.routeForIndex(index);
    if (foundRoute == null) {
      throw AppRouterException("Could not find route for index!");
    }
    final route = foundRoute.route;
    if (route is AppPageRoute && route.skip != null) {
      routeSkipResult = route.skip!(
        AppRouterPageState(
          name: route.name,
          fullpath: foundRoute.fullPath,
          extra: foundRoute.extra,
        ),
      );
    }
    return routeSkipResult;
  }
}
