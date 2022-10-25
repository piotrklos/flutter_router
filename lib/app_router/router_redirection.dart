import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'app_router_page_state.dart';
import 'configuration.dart';
import 'route.dart';
import 'route_finder.dart';
import 'router_exception.dart';

class AppRouterRedirector {
  final AppRouterConfiguration configuration;

  AppRouterRedirector(this.configuration);

  FutureOr<RouterPaths> redirect(
    FutureOr<RouterPaths> prevRouterPathsFuture,
    RouteFinder routeFinder, {
    List<RouterPaths>? redirectHistory,
    Object? extra,
  }) {
    if (prevRouterPathsFuture is RouterPaths) {
      return _processRedirect(
        prevRouterPathsFuture,
        extra: extra,
        routeFinder: routeFinder,
        redirectHistory: redirectHistory,
      );
    }
    return prevRouterPathsFuture.then<RouterPaths>(
      (value) {
        return _processRedirect(
          value,
          extra: extra,
          routeFinder: routeFinder,
          redirectHistory: redirectHistory,
        );
      },
    );
  }

  FutureOr<RouterPaths> _processRedirect(
    RouterPaths prevRouterPaths, {
    required RouteFinder routeFinder,
    required List<RouterPaths>? redirectHistory,
    required Object? extra,
  }) {
    redirectHistory ??= <RouterPaths>[prevRouterPaths];
    final FutureOr<String?> topRedirectResult = configuration.topRedirect(
      AppRouterPageState(
        name: null,
        fullpath: prevRouterPaths.location.toString(),
        extra: extra,
      ),
    );

    if (topRedirectResult is String?) {
      return _processTopLevelRedirect(
        topRedirectResult,
        extra: extra,
        prevRouterPaths: prevRouterPaths,
        redirectHistory: redirectHistory,
        routeFinder: routeFinder,
      );
    }
    return topRedirectResult.then<RouterPaths>(
      (value) {
        return _processTopLevelRedirect(
          value,
          extra: extra,
          prevRouterPaths: prevRouterPaths,
          redirectHistory: redirectHistory,
          routeFinder: routeFinder,
        );
      },
    );
  }

  FutureOr<RouterPaths> _processTopLevelRedirect(
    String? topRedirectLocation, {
    required RouterPaths prevRouterPaths,
    required RouteFinder routeFinder,
    required List<RouterPaths>? redirectHistory,
    required Object? extra,
  }) {
    if (topRedirectLocation != null) {
      final RouterPaths newRouterPaths = _getRouterPaths(
        topRedirectLocation,
        prevRouterPaths.location!,
        routeFinder,
        redirectHistory!,
      );
      if (newRouterPaths.last.exception != null) {
        return newRouterPaths;
      }
      return redirect(
        newRouterPaths,
        routeFinder,
        redirectHistory: redirectHistory,
        extra: extra,
      );
    }

    final FutureOr<String?> routeLevelRedirectResult = _getRouteLevelRedirect(
      prevRouterPaths,
      0,
    );
    if (routeLevelRedirectResult is String?) {
      return _processRouteLevelRedirect(
        routeLevelRedirectResult,
        extra: extra,
        prevRouterPaths: prevRouterPaths,
        redirectHistory: redirectHistory,
        routeFinder: routeFinder,
      );
    }
    return routeLevelRedirectResult.then<RouterPaths>(
      (value) {
        return _processRouteLevelRedirect(
          value,
          extra: extra,
          prevRouterPaths: prevRouterPaths,
          redirectHistory: redirectHistory,
          routeFinder: routeFinder,
        );
      },
    );
  }

  FutureOr<RouterPaths> _processRouteLevelRedirect(
    String? routeRedirectLocation, {
    required RouterPaths prevRouterPaths,
    required RouteFinder routeFinder,
    required List<RouterPaths>? redirectHistory,
    required Object? extra,
  }) {
    if (routeRedirectLocation != null) {
      final RouterPaths newRouterPaths = _getRouterPaths(
        routeRedirectLocation,
        prevRouterPaths.location!,
        routeFinder,
        redirectHistory!,
      );

      if (newRouterPaths.last.exception != null) {
        return newRouterPaths;
      }
      return redirect(
        newRouterPaths,
        routeFinder,
        redirectHistory: redirectHistory,
        extra: extra,
      );
    }
    return prevRouterPaths;
  }

  FutureOr<String?> _getRouteLevelRedirect(
    RouterPaths routerPaths,
    int currentCheckIndex,
  ) {
    if (currentCheckIndex >= routerPaths.length) {
      return null;
    }
    final FoundRoute? foundRoute = routerPaths.routeForIndex(currentCheckIndex);
    if (foundRoute == null) {
      return null;
    }
    FutureOr<String?> processRouteRedirect(String? newLocation) =>
        newLocation ??
        _getRouteLevelRedirect(
          routerPaths,
          currentCheckIndex + 1,
        );
    final route = foundRoute.route;
    FutureOr<String?> routeRedirectResult;
    if (route is AppPageRoute && route.redirect != null) {
      routeRedirectResult = route.redirect!(
        AppRouterPageState(
          name: route.name,
          fullpath: foundRoute.fullPath,
          extra: foundRoute.extra,
        ),
      );
    }
    if (routeRedirectResult is String?) {
      return processRouteRedirect(routeRedirectResult);
    }
    return routeRedirectResult.then<String?>(processRouteRedirect);
  }

  RouterPaths _getRouterPaths(
    String newLocation,
    String previousLocation,
    RouteFinder finder,
    List<RouterPaths> redirectHistory,
  ) {
    try {
      final RouterPaths newRouterPaths = finder.findForPath(
        newLocation,
        shouldBackToParent: false,
      );
      _addRedirect(
        redirectHistory,
        newRouterPaths,
        previousLocation,
        configuration.redirectLimit,
      );
      return newRouterPaths;
    } on _RedirectionError catch (e) {
      return _errorScreen(e.location, e.message);
    } on AppRouterException catch (e) {
      return _errorScreen(previousLocation, e.message);
    }
  }

  void _addRedirect(
    List<RouterPaths> redirects,
    RouterPaths newRouterPaths,
    String prevLocation,
    int redirectLimit,
  ) {
    if (redirects.contains(newRouterPaths)) {
      throw _RedirectionError(
        'redirect loop detected',
        <RouterPaths>[...redirects, newRouterPaths],
        prevLocation,
      );
    }
    if (redirects.length > redirectLimit) {
      throw _RedirectionError(
        'too many redirects',
        <RouterPaths>[...redirects, newRouterPaths],
        prevLocation,
      );
    }

    redirects.add(newRouterPaths);
  }

  RouterPaths _errorScreen(String location, String errorMessage) {
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

class _RedirectionError extends Error implements UnsupportedError {
  @override
  final String message;
  final List<RouterPaths> routePathsList;
  final String location;

  _RedirectionError(
    this.message,
    this.routePathsList,
    this.location,
  );

  @override
  String toString() => '${super.toString()} ${<String>[
        ...routePathsList.map(
          (RouterPaths foundRoutees) => foundRoutees.location.toString(),
        ),
      ].join(' => ')}';
}
