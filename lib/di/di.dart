import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

// final getIt = GetItBetterImplementation();
final getIt = GetIt.instance;

@InjectableInit()
Future<void> initDependencies() async {
  $initGetIt(getIt);
  await getIt.allReady();
}
