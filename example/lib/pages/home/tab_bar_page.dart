import 'package:flutter/cupertino.dart';

import '../../app_router/interface/tab_bar_state.dart';
import '../../app_router/interface/route.dart';

class TabBarPage extends StatelessWidget {
  final Widget child;
  final List<PBTabRouteItem> items;
  final TabBarState state;

  const TabBarPage({
    required this.child,
    required this.items,
    required this.state,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        CupertinoTabBar(
          currentIndex: state.currentIndex,
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
              index,
            );
          },
        ),
      ],
    );
  }

  void _onItemTapped(
    BuildContext context,
    int index,
  ) {
    state.changeTab(index, state.currentIndex == index);
  }
}
