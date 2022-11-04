import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'router.dart';
import 'location.dart';
import 'route_finder.dart';
import 'typedef.dart';
import 'configuration.dart';
import 'inherited_statefull_navigation_shell.dart';
import 'page_state.dart';
import 'route.dart';

class StatefulNavigationShell extends StatefulWidget {
  final AppRouterConfiguration configuration;
  final StatefulShellRoute shellRoute;
  final AppRouterPageState shellAppRouterState;
  final Navigator navigator;
  final RouterPaths routerPaths;

  const StatefulNavigationShell({
    required this.configuration,
    required this.shellRoute,
    required this.shellAppRouterState,
    required this.navigator,
    required this.routerPaths,
    required this.branchNavigatorBuilder,
    Key? key,
  }) : super(key: key);

  final ShellRouteBranchNavigatorBuilder branchNavigatorBuilder;

  @override
  State<StatefulWidget> createState() => StatefulNavigationShellState();
}

class StatefulNavigationShellState extends State<StatefulNavigationShell> {
  late StatefulShellRouteState _routeState;

  int _findCurrentIndex() {
    final List<ShellRouteBranchState> branchState = _routeState.branchStates;
    final int index = branchState.indexWhere(
      (e) => e.routeBranch.navigatorKey == widget.navigator.key,
    );
    return index < 0 ? 0 : index;
  }

  void _changeActiveBranch(
    ShellRouteBranchState branchState,
    RouterPaths? routerPaths,
  ) {
    if (routerPaths != null) {
      AppRouter.of(context).routerDelegate.replaceRouterPaths(routerPaths);
    } else {
      AppRouter.of(context).go(branchState.defaultLocation.path);
    }
  }

  AppRouterLocation _locationForRoute(BaseAppRoute route) {
    return widget.configuration.locationForRoute(route);
  }

  @override
  void initState() {
    super.initState();
    final List<ShellRouteBranchState> branchState = widget.shellRoute.branches
        .map((e) => ShellRouteBranchState(
              routeBranch: e,
              rootRoutePath: _locationForRoute(e.rootRoute),
            ))
        .toList();
    _routeState = StatefulShellRouteState(
      changeActiveBranch: _changeActiveBranch,
      route: widget.shellRoute,
      branchStates: branchState,
      currentIndex: 0,
    );
  }

  @override
  void dispose() {
    _routeState.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StatefulNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRouteState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRouteState();
  }

  void _updateRouteState() {
    final int currentIndex = _findCurrentIndex();

    final branchStates = _routeState.branchStates.toList();
    branchStates[currentIndex] = branchStates[currentIndex].copy(
      navigator: widget.navigator,
      routerPaths: widget.routerPaths,
    );

    if (widget.shellRoute.preloadBranches) {
      for (int i = 0; i < branchStates.length; i++) {
        if (i != currentIndex && branchStates[i].navigator == null) {
          final Navigator? navigator = widget.branchNavigatorBuilder(
            context,
            _routeState,
            i,
          );
          branchStates[i] = branchStates[i].copy(
            navigator: navigator,
          );
        }
      }
    }

    _routeState = StatefulShellRouteState(
      changeActiveBranch: _changeActiveBranch,
      route: widget.shellRoute,
      branchStates: branchStates,
      currentIndex: currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStatefulNavigationShell(
      routeState: _routeState,
      child: Builder(
        builder: (newContext) {
          final shellRouteBuilder = widget.shellRoute.builder;
          return shellRouteBuilder(
            newContext,
            widget.shellAppRouterState,
            _IndexedStackedRouteBranchContainer(routeState: _routeState),
          );
        },
      ),
    );
  }
}

class _IndexedStackedRouteBranchContainer extends StatelessWidget {
  const _IndexedStackedRouteBranchContainer({
    required this.routeState,
  });

  final StatefulShellRouteState routeState;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = routeState.branchStates
        .mapIndexed(
          (index, item) => _buildRouteBranchContainer(context, index, item),
        )
        .toList();

    return IndexedStack(
      index: routeState.currentIndex,
      children: children,
    );
  }

  Widget _buildRouteBranchContainer(
    BuildContext context,
    int index,
    ShellRouteBranchState routeBranch,
  ) {
    final Navigator? navigator = routeBranch.navigator;
    if (navigator == null) {
      return const SizedBox.shrink();
    }
    final bool isActive = index == routeState.currentIndex;
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: _buildProvider(
          child: navigator,
          branchState: routeBranch,
        ),
      ),
    );
  }

  Widget _buildProvider({
    required Widget child,
    required ShellRouteBranchState branchState,
  }) {
    final providers = branchState.providers;
    if (providers.isEmpty) {
      return child;
    }
    return MultiBlocProvider(
      providers: providers.map((e) => e.blocProvider).toList(),
      child: child,
    );
  }
}
