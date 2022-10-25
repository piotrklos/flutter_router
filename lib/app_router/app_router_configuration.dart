// import 'package:flutter/material.dart';

// import 'app_router.dart';
// import 'app_router_cubit_provider.dart';
// import 'configuration.dart';
// import 'information_parser_with_redirection_and_skip.dart';
// import 'information_provider.dart';
// import 'inherited_router.dart';
// import 'route.dart';
// import 'route_finder.dart';
// import 'router_delegate.dart';
// import 'router_redirection.dart';
// import 'router_skipper.dart';
// import 'typedef.dart';

// class AppRouterConfiguration {
//   late final AppRouteInformationParserWithRedirectionAndSkip _routeInformationParser;
//   late final AppRouteInformationProvider _routeInformationProvider;
//   late final AppRouterDelegate _routerDelegate;
//   late final AppRouterRoutesConfiguration _configuration;
//   late final AppRouterCubitProvider _cubitProvider;

//   AppRouteInformationParserWithRedirectionAndSkip get routeInformationParser =>
//       _routeInformationParser;
//   AppRouteInformationProvider get routeInformationProvider =>
//       _routeInformationProvider;
//   AppRouterDelegate get routerDelegate => _routerDelegate;
//   AppRouterRoutesConfiguration get configuration => _configuration;
//   AppRouterCubitProvider get cubitProvider => _cubitProvider;

//   AppRouterConfiguration({
//     required List<BaseAppRoute> routes,
//     required AppRouterWidgetBuilder errorBuilder,
//     required AppRouter appRouter,
//     AppRouterRedirect? redirect,
//     int redirectLimit = 5,
//     GlobalKey<NavigatorState>? navigatorKey,
//     List<NavigatorObserver>? observers,
//     String? restorationScopeId,
//     String? initialLocation,
//     Listenable? refreshListenable,
//   }) {
//     _configuration = AppRouterRoutesConfiguration(
//       globalNavigatorKey: navigatorKey ?? GlobalKey<NavigatorState>(),
//       topLevelRoutes: routes,
//       topRedirect: redirect ?? (_, __) => null,
//       redirectLimit: redirectLimit,
//     );

//     _cubitProvider = AppRouterCubitProvider(
//       _configuration,
//     );

//     _routeInformationParser = AppRouteInformationParserWithRedirectionAndSkip(
//       RouteFinder(_configuration),
//       _cubitProvider,
//       AppRouterRedirector(_configuration),
//       AppRouterSkipper(_configuration),
//     );

//     _routeInformationProvider = AppRouteInformationProvider(
//       initialRouteInformation: RouteInformation(
//         location: initialLocation ?? "/",
//       ),
//       refreshListenable: refreshListenable,
//     );

//     _routerDelegate = AppRouterDelegate(
//       configuration: _configuration,
//       errorBuilder: errorBuilder,
//       observers: [...observers ?? [], appRouter],
//       restorationScopeId: restorationScopeId,
//       builderWithNavigator: (context, _, nav) => InheritedAppRouter(
//         appRouter: appRouter,
//         child: nav,
//       ),
//     );
//   }
// }
