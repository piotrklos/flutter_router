import 'package:app_router/src/app_router.dart';
import 'package:app_router/src/route.dart';
import 'package:app_router/src/route_finder.dart';
import 'package:app_router/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sample_pages.dart';

Future<void> simulateAndroidBackButton(WidgetTester tester) async {
  final ByteData message = const JSONMethodCodec().encodeMethodCall(
    const MethodCall('popRoute'),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    message,
    (_) {},
  );
}

class AppRouterSpy extends AppRouter {
  AppRouterSpy({
    required List<BaseAppRoute> routes,
  }) : super(
          routes: routes,
          errorBuilder: (_, __) => const ErrorScreen(message: ""),
        );

  String? routerLocation;
  String? routerName;
  Object? extra;
  bool? backToParent;
  bool? popped;

  @override
  Future<T?> go<T extends Object?>(
    String location, {
    Object? extra,
    bool backToParent = false,
  }) {
    routerLocation = location;
    this.extra = extra;
    this.backToParent = backToParent;
    return SynchronousFuture(null);
  }

  @override
  Future<T?> goNamed<T extends Object?>(
    String name, {
    Object? extra,
    bool backToParent = false,
  }) {
    routerName = name;
    this.extra = extra;
    this.backToParent = backToParent;
    return SynchronousFuture(null);
  }

  @override
  Future<T?> push<T extends Object?>(
    String location, {
    Object? extra,
  }) {
    routerLocation = location;
    this.extra = extra;
    return SynchronousFuture(null);
  }

  @override
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? extra,
  }) {
    routerName = name;
    this.extra = extra;
    return SynchronousFuture(null);
  }

  @override
  void pop<T extends Object?>([T? result]) {
    popped = true;
  }
}

class TestHelper {
  static RouterPaths createRouterPaths(
    List<BaseAppRoute> routes,
  ) {
    final foundsRoutes = createFoundRoutes(routes);
    if (foundsRoutes.isEmpty) {
      return RouterPaths.empty();
    }

    return RouterPaths(foundsRoutes);
  }

  static List<FoundRoute> createFoundRoutes(
    List<BaseAppRoute> routes,
  ) {
    if (routes.isEmpty) {
      return [];
    }

    String fullPath = "";

    final foundsRoutes = routes.map((route) {
      if (route is AppPageRoute) {
        fullPath = PathUtils.joinPaths(fullPath, route.path);
        // if (route.path.startsWith("/")) {
        // fullPath = fullPath + route.path;
        // } else {
        // fullPath = fullPath + "/" + route.path;
        // }
        final foundRoute = FoundRoute.test(
          route: route,
          fullPath: fullPath,
        );
        return foundRoute;
      } else {
        return FoundRoute.factory(
          fullpath: fullPath,
          route: route,
          remainPathToCheck: "",
          extra: null,
        )!;
      }
    }).toList();

    return foundsRoutes;
  }
}

class TestPageRoute {
  final String name;
  final bool isAppPage;
  final VoidCallback? onPop;
  final VoidCallback? onPush;

  TestPageRoute({
    required this.name,
    this.isAppPage = true,
    this.onPop,
    this.onPush,
  });

  BaseAppRoute appRoute({
    List<BaseAppRoute> routes = const [],
  }) {
    if (isAppPage) {
      return AppPageRoute(
        path: name,
        name: name,
        builder: (_, __) => Container(),
        onPop: onPop,
        onPush: onPush,
        routes: routes,
      );
    }
    return ShellRoute(
      builder: (context, state, child) {
        return Container();
      },
      routes: routes,
      onPop: onPop,
    );
  }
}

class MockFoundRoute extends FoundRoute {
  MockFoundRoute(
    String name, {
    VoidCallback? onPop,
    VoidCallback? onPush,
  }) : super.test(
          route: AppPageRoute(
            path: name,
            name: name,
            builder: (_, __) => Container(),
            onPop: onPop,
            onPush: onPush,
          ),
          fullPath: "/$name",
        );
}
