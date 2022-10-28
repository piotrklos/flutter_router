import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'app_router/interface/inherited_router.dart';
import 'app_router/interface/router.dart';
import 'di/di.dart';
import 'service/sample_bloc_observer.dart';

void main() async {
  await initDependencies();
  Bloc.observer = SampleBlocObserver();
  final routerInterface = GetIt.instance.get<PBAppNavigator>();
  await routerInterface.init();
  runApp(MyApp(
    routerInterface: routerInterface,
  ));
}

class MyApp extends StatelessWidget {
  final PBAppNavigator routerInterface;
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
