import 'package:flutter/material.dart';

import '../../app_router/interface/route.dart';
import '../../app_router/interface/router.dart';
import '../../app_router/interface/tab_bar_item_state.dart';

class TabBarPage extends StatelessWidget {
  final int currentIndex;
  final List<PBTabBarItemState> itemsState;
  final Widget body;
  final List<PBTabRouteItem> tabRouteItems;

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
    PBTabBarItemState itemState,
  ) {
    // if (AppRouter.of(context).currentLocation == itemState.item.rootRoutePath) {
    //   print("primary scroll");
    //   PrimaryScrollController.of(context)?.animateTo(
    //     0,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.linear,
    //   );
    // } else
    if (PBAppNavigator.of(context).currentLocation ==
        itemState.currentLocation) {
      PBAppNavigator.of(context).goNamed(itemState.rootRouteLocation.name);
    } else {
      PBAppNavigator.of(context).goNamed(itemState.currentLocation.name);
    }
  }
}
