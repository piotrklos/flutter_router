import 'package:flutter/material.dart';

import '../../app_router/app_router.dart';
import '../../app_router/stacked_navigation_shell.dart';
import '../../app_router_config/app_route.dart';

class TabBarPage extends StatelessWidget {
  final int currentIndex;
  final List<StackedNavigationItemState> itemsState;
  final Widget body;
  final List<TabRouteItem> tabRouteItems;

  const TabBarPage({
    required this.currentIndex,
    required this.itemsState,
    required this.body,
    required this.tabRouteItems,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: tabRouteItems
            .map(
              (e) => BottomNavigationBarItem(
                icon: Icon(
                  e.iconData,
                ),
                label: e.name,
              ),
            )
            .toList(),
        currentIndex: currentIndex,
        onTap: (int tappedIndex) => _onItemTapped(
          context,
          itemsState[tappedIndex],
        ),
      ),
    );
  }

  void _onItemTapped(
    BuildContext context,
    StackedNavigationItemState itemState,
  ) {
    // if (AppRouter.of(context).currentLocation == itemState.item.rootRoutePath) {
    //   print("primary scroll");
    //   PrimaryScrollController.of(context)?.animateTo(
    //     0,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.linear,
    //   );
    // } else
    if (AppRouter.of(context).currentLocation == itemState.currentLocation) {
      AppRouter.of(context).go(itemState.item.rootRoutePath);
    } else {
      AppRouter.of(context).go(itemState.currentLocation);
    }
  }
}
