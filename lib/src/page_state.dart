import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../app_router.dart';

@immutable
class AppRouterPageState {
  final String? name;
  final String fullpath;
  final Object? extra;
  final ValueKey<String> pageKey;
  final Exception? exception;

  AppRouterPageState({
    required this.name,
    required this.fullpath,
    this.extra,
    this.exception,
    ValueKey<String>? pageKey,
  }) : pageKey = pageKey ?? ValueKey<String>(fullpath);
}

@immutable
class StatefulShellRouteState extends Equatable {
  final StatefulShellRoute route;
  final List<ShellRouteBranchState> branchStates;
  final int currentIndex;
  final void Function(ShellRouteBranchState, RouterPaths?) _changeActiveBranch;

  const StatefulShellRouteState({
    required void Function(
      ShellRouteBranchState,
      RouterPaths?,
    )
        changeActiveBranch,
    required this.route,
    required this.branchStates,
    required this.currentIndex,
  }) : _changeActiveBranch = changeActiveBranch;

  List<Navigator?> get navigators {
    return branchStates.map((e) => e.navigator).toList();
  }

  void goToBranch(
    int index, {
    bool resetLocation = false,
  }) {
    _changeActiveBranch(
      branchStates[index],
      resetLocation ? null : branchStates[index]._routerPaths,
    );
  }

  @override
  List<Object?> get props => [route, branchStates, currentIndex];

  void dispose() {
    for (var state in branchStates) {
      state.dispose();
    }
  }
}

@immutable
class ShellRouteBranchState extends Equatable {
  final ShellRouteBranch routeBranch;
  final Navigator? navigator;
  final RouterPaths? _routerPaths;
  final AppRouterLocation _rootRoutePath;
  final List<AppRouterBlocProvider> _tempProvidersList = [];

  ShellRouteBranchState({
    required this.routeBranch,
    required AppRouterLocation rootRoutePath,
    this.navigator,
    RouterPaths? routerPaths,
  })  : _routerPaths = routerPaths,
        _rootRoutePath = rootRoutePath {
    _buildProvider();
  }

  ShellRouteBranchState copy({
    Navigator? navigator,
    RouterPaths? routerPaths,
  }) {
    return ShellRouteBranchState(
      routeBranch: routeBranch,
      rootRoutePath: _rootRoutePath,
      navigator: navigator ?? this.navigator,
      routerPaths: routerPaths ?? _routerPaths,
    );
  }

  List<AppRouterBlocProvider> get providers => _tempProvidersList;

  AppRouterLocation get defaultLocation =>
      routeBranch.defaultLocation ?? _rootRoutePath;

  @override
  List<Object?> get props => [
        routeBranch,
        _rootRoutePath,
        navigator,
        _routerPaths,
      ];

  void _buildProvider() {
    final providers = routeBranch.providersBuilder?.call() ?? [];
    if (_tempProvidersList.isNotEmpty) {
      _tempProvidersList.clear();
    }
    _tempProvidersList.addAll(providers);
  }

  void dispose() {
    for (var bloc in _tempProvidersList) {
      bloc.close();
    }
    _tempProvidersList.clear();
  }
}
