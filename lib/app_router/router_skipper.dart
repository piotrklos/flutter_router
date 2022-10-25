import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'app_router_page_state.dart';
import 'configuration.dart';
import 'route.dart';
import 'route_finder.dart';
import 'router_exception.dart';
import 'typedef.dart';

class AppRouterSkipper {
  final AppRouterConfiguration configuration;

  AppRouterSkipper(this.configuration);

  FutureOr<RouterPaths> skip(
    BuildContext context,
    FutureOr<RouterPaths> routerPathsFuture,
    RouteFinder routeFinder,
  ) {
    if (routerPathsFuture is RouterPaths) {
      return _processSkip(
        routerPathsFuture,
        context: context,
        routeFinder: routeFinder,
        index: routerPathsFuture.length - 1,
      );
    }
    return routerPathsFuture.then<RouterPaths>(
      (value) {
        return _processSkip(
          value,
          context: context,
          routeFinder: routeFinder,
          index: value.length - 1,
        );
      },
    );
  }

  FutureOr<RouterPaths> _processSkip(
    RouterPaths routerPaths, {
    required BuildContext context,
    required RouteFinder routeFinder,
    required int index,
  }) {
    if (index == 0) {
      return routerPaths;
    }
    if (routerPaths.isEmpty) {
      return routerPaths;
    }

    final FutureOr<SkipOption?> skipResult = _getSkipper(
      context,
      routerPaths,
      index,
    );

    if (skipResult is SkipOption?) {
      return _processRouteLevelSkipper(
        skipResult,
        context: context,
        routeFinder: routeFinder,
        routerPaths: routerPaths,
        index: index,
      );
    }
    return skipResult.then<RouterPaths>(
      (value) {
        return _processRouteLevelSkipper(
          value,
          context: context,
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
    required BuildContext context,
    required RouteFinder routeFinder,
    required int index,
  }) {
    if (skipOption != null) {
      final RouterPaths newRouterPaths = _getRouterPaths(
        skipOption,
        routerPaths,
        routeFinder,
        index,
      );

      return _processSkip(
        newRouterPaths,
        context: context,
        index: index - 1,
        routeFinder: routeFinder,
      );
    }
    return _processSkip(
      routerPaths,
      context: context,
      index: index - 1,
      routeFinder: routeFinder,
    );
  }

  FutureOr<SkipOption?> _getSkipper(
    BuildContext context,
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
        context,
        AppRouterPageState(
          name: route.name,
          fullpath: foundRoute.fullPath,
          extra: foundRoute.extra,
        ),
      );
    }
    return routeSkipResult;
  }

  RouterPaths _getRouterPaths(
    SkipOption skipOption,
    RouterPaths routerPaths,
    RouteFinder finder,
    int index,
  ) {
    try {
      final newRoutes = finder.proccessSkipToPaths(
        routerPaths: routerPaths,
        skipOption: skipOption,
        index: index,
      );
      if (newRoutes == null) {
        throw AppRouterException("Could not find child to last route!");
      }
      return newRoutes;
    } on AppRouterException catch (e) {
      return _errorScreen(e.message, "");
    }
  }

  RouterPaths _errorScreen(String errorMessage, String location) {
    final Exception error = Exception(errorMessage);
    return RouterPaths(
      [
        FoundRoute.error(
          fullPath: location,
          exception: error,
        ),
      ],
    );
  }
}
