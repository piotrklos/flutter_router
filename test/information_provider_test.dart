import 'package:app_router/src/information_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const initRoute = RouteInformation(location: '/');
  const newRoute = RouteInformation(location: '/newRoute');
  testWidgets('notifies its listeners when set new value', (
    WidgetTester tester,
  ) async {
    final provider = AppRouteInformationProvider(
      initialRouteInformation: initRoute,
    );
    provider.addListener(expectAsync0(() {}));
    provider.value = newRoute;
  });

  testWidgets('notifies its listeners when didPushRouteInformation', (
    WidgetTester tester,
  ) async {
    final provider = AppRouteInformationProvider(
      initialRouteInformation: initRoute,
    );
    provider.addListener(expectAsync0(() {}));
    provider.didPushRouteInformation(newRoute);
  });

  testWidgets('notifies its listeners when push new route', (
    WidgetTester tester,
  ) async {
    final provider = AppRouteInformationProvider(
      initialRouteInformation: initRoute,
    );
    provider.addListener(expectAsync0(() {}));
    provider.didPushRoute("newRoute");
  });
}
