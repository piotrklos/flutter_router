import 'package:app_router/app_router.dart';
import 'package:flutter/cupertino.dart';

import '../../app_router/interface/route.dart';

class TabBarPage extends StatelessWidget {
  final Widget child;
  final List<PBTabRouteItem> items;

  const TabBarPage({
    required this.child,
    required this.items,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    final shellState = StatefulShellRoute.of(context);

    return Column(
      children: [
        Expanded(child: child),
        CupertinoTabBar(
          currentIndex: shellState.currentIndex,
          iconSize: 16,
          items: items
              .map(
                (e) => BottomNavigationBarItem(
                  icon: Icon(
                    e.iconData,
                  ),
                  label: e.name,
                ),
              )
              .toList(),
          onTap: (index) {
            _onItemTapped(
              context,
              shellState,
              index,
            );
          },
        ),
      ],
    );
  }

  void _onItemTapped(
    BuildContext context,
    StatefulShellRouteState shellRouteState,
    int index,
  ) {
    if (shellRouteState.currentIndex == index) {
      shellRouteState.goToBranch(index, resetLocation: true);
    } else {
      shellRouteState.goToBranch(index);
    }
  }
}
