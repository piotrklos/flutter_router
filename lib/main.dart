import 'package:flutter/material.dart';

import 'app_router/app_router.dart';
import 'app_router_config/app_router_config.dart';
import 'di/di.dart';

void main() async {
  await initDependencies();
  final routerConfig = getIt.get<AppRouterConfig>();
  routerConfig.init();
  runApp(MyApp(
    appRouter: routerConfig.appRouter,
  ));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({
    super.key,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.black,
        ),
      ),
    );
  }
}
