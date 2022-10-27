import 'package:example/app_router/interface/route.dart';

import '../interface/app_router_bloc_provider.dart';
import 'bloc_helper.dart';

class PBTabRouteWithDependencie extends PBTabRoute {
  final Map<PBTabRouteItem, List<String>> dependenciesMap = {};
  final Map<String, PBAppRouterBlocProvider> dependenciesProvider = {};

  PBTabRouteWithDependencie({
    required List<PBTabRouteItem> items,
  }) : super(items: items) {
    for (var tab in items) {
      for (var cubitType in tab.cubitsTypes) {
        dependenciesMap.putIfAbsent(tab, () => []);
        dependenciesMap[tab]!.add(cubitType.toString());

        dependenciesProvider.putIfAbsent(
          cubitType.toString(),
          () => BlocHelper.getBlocByType(cubitType),
        );
      }
    }
  }
}
