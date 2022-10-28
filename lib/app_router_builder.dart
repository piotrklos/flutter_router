import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router_bloc_provider.dart';
import 'app_router_builder_helper.dart';
import 'app_router_location.dart';
import 'app_router_page_state.dart';
import 'configuration.dart';
import 'route.dart';
import 'route_finder.dart';
import 'typedef.dart';

class AppRouterBuilder {
  final AppRouterBuilderWithNavigator _builderWithNavigator;
  final AppRouterWidgetBuilder _errorBuilder;
  final AppRouterConfiguration _configuration;
  final String? restorationScopeId;
  final List<NavigatorObserver> observers;
  final AppRouterBuilderHelper _helper;

  PageBuilderForAppType? _pageBuilderForAppType;

  AppRouterBuilder({
    required AppRouterBuilderWithNavigator builderWithNavigator,
    required AppRouterWidgetBuilder errorBuilder,
    required AppRouterConfiguration configuration,
    required this.restorationScopeId,
    required this.observers,
  })  : _builderWithNavigator = builderWithNavigator,
        _errorBuilder = errorBuilder,
        _configuration = configuration,
        _helper = AppRouterBuilderHelper();

  Widget build({
    required BuildContext context,
    required RouterPaths routerPaths,
    required ValueSetter<dynamic> onPop,
  }) {
    if (routerPaths.isEmpty) {
      return const SizedBox.shrink();
    }
    try {
      return _builderWithNavigator(
        context,
        AppRouterPageState(
          name: null,
          fullpath: routerPaths.location!.path,
        ),
        _buildNavigator(
          onPop: onPop,
          pages: _buildPagesList(
            context: context,
            routerPaths: routerPaths,
            onPop: onPop,
            navigatorKey: _configuration.globalNavigatorKey,
          ),
          navigatorKey: _configuration.globalNavigatorKey,
          observers: observers,
        ),
      );
    } on _AppRouterRouteBuilderError catch (e) {
      return _buildNavigatorOnlyWithError(
        context: context,
        e: e,
        location: routerPaths.location!,
        navigatorKey: _configuration.globalNavigatorKey,
        onPop: onPop,
      );
    }
  }

  List<Page> _buildPagesList({
    required BuildContext context,
    required RouterPaths routerPaths,
    required ValueSetter<dynamic> onPop,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    final Map<GlobalKey<NavigatorState>, List<Page>> keyToPages = {};
    try {
      _buildPagesRecursive(
        context: context,
        routerPaths: routerPaths,
        keyToPages: keyToPages,
        navigatorKey: navigatorKey,
        onPop: onPop,
        startIndex: 0,
      );
      return keyToPages[navigatorKey]!;
    } catch (e) {
      return [
        _buildErrorPage(
          context: context,
          location: routerPaths.location!,
          builderError: _AppRouterRouteBuilderError(
            "Build Page List error",
            exception: Exception(e),
          ),
        ),
      ];
    }
  }

  Navigator _buildNavigator({
    required ValueSetter<dynamic> onPop,
    required List<Page> pages,
    Key? navigatorKey,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) {
    return Navigator(
      key: navigatorKey,
      restorationScopeId: restorationScopeId,
      pages: pages,
      observers: observers,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        onPop(result);
        return true;
      },
    );
  }

  Page<dynamic> _buildPage({
    required BuildContext context,
    required Widget child,
    required AppRouterPageState state,
  }) {
    _checkAndCacheAppType(context);
    return _pageBuilderForAppType!(
      key: state.pageKey,
      name: state.name ?? state.fullpath,
      restorationId: state.pageKey.value,
      child: child,
    );
  }

  /// Error

  Widget _buildNavigatorOnlyWithError({
    required BuildContext context,
    required _AppRouterRouteBuilderError e,
    required AppRouterLocation location,
    required ValueSetter<dynamic> onPop,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    return _buildNavigator(
      onPop: onPop,
      pages: [
        _buildErrorPage(
          context: context,
          builderError: e,
          location: location,
        ),
      ],
      navigatorKey: navigatorKey,
    );
  }

  Page _buildErrorPage({
    required BuildContext context,
    required AppRouterLocation location,
    _AppRouterRouteBuilderError? builderError,
  }) {
    final state = AppRouterPageState(
      fullpath: location.path,
      name: location.name,
      exception: Exception(builderError),
    );

    return _buildPage(
      context: context,
      child: _errorBuilder(context, state),
      state: state,
    );
  }

  /// Other

  void _checkAndCacheAppType(BuildContext context) {
    _pageBuilderForAppType ??= _helper.getPageBuilderForCorrectType(context);
  }

  void _buildPagesRecursive({
    required BuildContext context,
    required RouterPaths routerPaths,
    required ValueSetter<dynamic> onPop,
    required GlobalKey<NavigatorState> navigatorKey,
    required int startIndex,
    required Map<GlobalKey<NavigatorState>, List<Page<dynamic>>> keyToPages,
  }) {
    if (startIndex >= routerPaths.length) {
      return;
    }
    final foundRoute = routerPaths.routeForIndex(startIndex);
    if (foundRoute == null) {
      throw _AppRouterRouteBuilderError(
        "Colud not find route for passed index",
      );
    }
    if (foundRoute.exception != null) {
      throw _AppRouterRouteBuilderError(
        'Found route error found during build phase',
      );
    }
    final parentsCubitProviders = routerPaths
        .parentsRoutesFor(foundRoute)
        .map<List<AppRouterBlocProvider>>(
          (e) {
            if (e.route is AppPageRoute) {
              return (e.route as AppPageRoute).providers;
            }
            return [];
          },
        )
        .expand((e) => e)
        .toList();
    final route = foundRoute.route;
    final state = _buildState(foundRoute);

    if (route is AppPageRoute) {
      final appRouteNavKey = route.parentNavigatorKey ?? navigatorKey;
      final page = _buildPageForRoute(
        context: context,
        foundRoute: foundRoute,
        state: state,
        parentsCubitProviders: parentsCubitProviders,
      );
      keyToPages.putIfAbsent(appRouteNavKey, () => []).add(page);
      _buildPagesRecursive(
        context: context,
        startIndex: startIndex + 1,
        keyToPages: keyToPages,
        navigatorKey: navigatorKey,
        onPop: onPop,
        routerPaths: routerPaths,
      );
    } else if (route is ShellRouteBase) {
      if (startIndex + 1 >= routerPaths.length) {
        throw _AppRouterRouteBuilderError(
          'Shell routes must always have child routes',
        );
      }
      final parentNavigatorKey = navigatorKey;
      keyToPages.putIfAbsent(parentNavigatorKey, () => []);
      final int shellPageIdx = keyToPages[parentNavigatorKey]!.length;
      final childRoute = routerPaths.routeForIndex(startIndex + 1)?.route;
      if (childRoute == null) {
        throw _AppRouterRouteBuilderError('Child route must not be empty!');
      }
      final shellNavigatorKey = route.navigatorKeyForChildRoute(childRoute);
      keyToPages.putIfAbsent(shellNavigatorKey, () => []);

      /// build remaining pages
      _buildPagesRecursive(
        context: context,
        startIndex: startIndex + 1,
        keyToPages: keyToPages,
        navigatorKey: shellNavigatorKey,
        onPop: onPop,
        routerPaths: routerPaths,
      );

      final navigatorChild = _buildNavigator(
        onPop: onPop,
        pages: keyToPages[shellNavigatorKey]!,
        navigatorKey: shellNavigatorKey,
      );

      final routePage = _buildPageForRoute(
        context: context,
        state: state,
        foundRoute: foundRoute,
        childWidget: navigatorChild,
        parentsCubitProviders: parentsCubitProviders,
      );

      keyToPages
          .putIfAbsent(parentNavigatorKey, () => [])
          .insert(shellPageIdx, routePage);
    }
  }

  Page _buildPageForRoute({
    required BuildContext context,
    required AppRouterPageState state,
    required FoundRoute foundRoute,
    required List<AppRouterBlocProvider> parentsCubitProviders,
    Widget? childWidget,
  }) {
    return _buildPage(
      context: context,
      state: state,
      child: _callRouteBuilder(
        context: context,
        state: state,
        foundRoute: foundRoute,
        childWidget: childWidget,
        parentsCubitProviders: parentsCubitProviders,
      ),
    );
  }

  AppRouterPageState _buildState(FoundRoute foundRoute) {
    final route = foundRoute.route;
    String? name = '';
    if (route is AppPageRoute) {
      name = route.name;
    }
    return AppRouterPageState(
      name: name,
      fullpath: foundRoute.fullPath,
      extra: foundRoute.extra,
      pageKey: foundRoute.pageKey,
    );
  }

  Widget _callRouteBuilder({
    required BuildContext context,
    required AppRouterPageState state,
    required FoundRoute foundRoute,
    required List<AppRouterBlocProvider> parentsCubitProviders,
    Widget? childWidget,
  }) {
    final route = foundRoute.route;
    Widget? buildedChild;

    if (route is AppPageRoute) {
      if (route.providers.isNotEmpty) {
        buildedChild = MultiBlocProvider(
          providers: route.providers.map((e) => e.blocProvider).toList(),
          child: route.builder(context, state),
        );
      } else {
        buildedChild = route.builder(context, state);
      }
    } else if (route is ShellRouteBase) {
      if (childWidget == null) {
        throw _AppRouterRouteBuilderError(
          'Attempt to build ShellRoute without a child widget',
        );
      }
      buildedChild = route.builder(context, state, childWidget);
    }
    if (buildedChild != null) {
      if (parentsCubitProviders.isNotEmpty) {
        return MultiBlocProvider(
          providers: parentsCubitProviders.map((e) => e.blocProvider).toList(),
          child: buildedChild,
        );
      }
      return buildedChild;
    }

    throw _AppRouterRouteBuilderError('Unsupported route type $route');
  }
}

class _AppRouterRouteBuilderError extends Error {
  _AppRouterRouteBuilderError(
    this.message, {
    this.exception,
  });

  final String message;
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}
