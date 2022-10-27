import 'package:flutter/material.dart';

import 'app_router/interface/inherited_router.dart';
import 'app_router/interface/router.dart';
import 'di/di.dart';

void main() async {
  await initDependencies();
  final routerInterface = getIt.get<PBAppRouter>();
  await routerInterface.init();
  runApp(MyApp(
    routerInterface: routerInterface,
  ));
}

class MyApp extends StatelessWidget {
  final PBAppRouter routerInterface;
  const MyApp({
    required this.routerInterface,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InheritedPBAppRouter(
      appRouter: routerInterface,
      child: MaterialApp.router(
        routeInformationParser: routerInterface.routeInformationParser,
        routerDelegate: routerInterface.routerDelegate,
        backButtonDispatcher: routerInterface.backButtonDispatcher,
        routeInformationProvider: routerInterface.routeInformationProvider,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
