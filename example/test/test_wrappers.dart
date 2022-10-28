import 'package:example/app_router/implementation/app_router_impl.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';

class TestWrappers {
  static Future<Widget> preparePageWrapper({
    required Widget child,
    NavigatorObserver? observer,
  }) {
    return _prepareApp();
  }

  static Future<Widget> _prepareApp() async {
    final routerConfig = AppRotuerImplementation();
    routerConfig.init();
    return MyApp(
      routerInterface: routerConfig,
    );
  }
}
