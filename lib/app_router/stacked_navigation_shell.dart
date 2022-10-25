import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router.dart';
import 'app_router_page_state.dart';
import 'typedef.dart';

class StackedNavigationItem {
  final String rootRoutePath;
  final GlobalKey<NavigatorState> navigatorKey;
  final List<BlocProvider<StateStreamableSource<Object?>>> providers;

  StackedNavigationItem({
    required this.rootRoutePath,
    required this.navigatorKey,
    this.providers = const [],
  });
}

class StackedNavigationItemState {
  final StackedNavigationItem item;
  String? lastLocation;
  Navigator? navigator;

  StackedNavigationItemState(this.item);

  String get currentLocation => lastLocation ?? item.rootRoutePath;
}

class StackedNavigationShell extends StatefulWidget {
  final Navigator currentNavigator;
  final AppRouterPageState currentRouterState;
  final List<StackedNavigationItem> stackItems;
  final StackedNavigationScaffoldBuilder? scaffoldBuilder;

  const StackedNavigationShell({
    required this.currentNavigator,
    required this.currentRouterState,
    required this.stackItems,
    this.scaffoldBuilder,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StackedNavigationShellState();
}

class _StackedNavigationShellState extends State<StackedNavigationShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<StackedNavigationItemState> _items;

  int _findCurrentIndex() {
    final int index = _items.indexWhere(
      (i) => i.item.navigatorKey == widget.currentNavigator.key,
    );
    return index < 0 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    _items = widget.stackItems
        .map(
          (i) => StackedNavigationItemState(i),
        )
        .toList();
  }

  @override
  void didUpdateWidget(covariant StackedNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateForCurrentTab();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateForCurrentTab();
  }

  void _updateForCurrentTab() {
    _currentIndex = _findCurrentIndex();
    final StackedNavigationItemState itemState = _items[_currentIndex];
    itemState.navigator = widget.currentNavigator;

    itemState.lastLocation = AppRouter.of(context).currentLocation;
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBuilder = widget.scaffoldBuilder;
    if (scaffoldBuilder != null) {
      return scaffoldBuilder(
        context,
        _currentIndex,
        _items,
        _buildIndexStack(context),
      );
    } else {
      return _buildIndexStack(context);
    }
  }

  Widget _buildIndexStack(BuildContext context) {
    final List<Widget> children = _items
        .mapIndexed(
          (index, item) => _buildNavigator(context, index, item),
        )
        .toList();

    return IndexedStack(
      index: _currentIndex,
      children: children,
    );
  }

  Widget _buildNavigator(
    BuildContext context,
    int index,
    StackedNavigationItemState navigationItem,
  ) {
    final Navigator? navigator = navigationItem.navigator;
    if (navigator == null) {
      return const SizedBox.shrink();
    }
    final bool isActive = index == _currentIndex;
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: _buildProvider(
          child: navigator,
          navigationItem: navigationItem,
        ),
      ),
    );
  }

  Widget _buildProvider({
    required Widget child,
    required StackedNavigationItemState navigationItem,
  }) {
    if (navigationItem.item.providers.isEmpty) {
      return child;
    }
    return MultiBlocProvider(
      providers: navigationItem.item.providers,
      child: child,
    );
  }
}
