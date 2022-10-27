import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'app_router_bloc_provider.dart';
import 'typedef.dart';

export 'skipper.dart';

abstract class IRoute {
  IRoute? _parent;
  IRoute? get parent => _parent;

  final List<IRoute> _routes = [];

  List<IRoute> get routes => _routes;

  void addRoute(IRoute route) {
    route._parent = this;
    _routes.add(route);
  }

  String get fullpath {
    if (_parent == null) {
      return "/$_route";
    }
    if (this is! PBPageRoute) {
      return "";
    }
    return "${_parent!.fullpath}/$_route";
  }

  String get _route {
    if (this is PBPageRoute) {
      return (this as PBPageRoute)._path;
    }
    return "";
  }
}

class PBTabRoute extends IRoute {
  final List<PBTabRouteItem> items;

  PBTabRoute({
    required this.items,
  });
}

class PBPageRoute extends IRoute {
  final String name;
  final String _path;
  final PBAppRouteWidgetBuilder builder;
  final PBAppRouteSkipper? skipper;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final List<PBAppRouterBlocProvider> Function(
    PBCubitGetter cubitGetter,
  )? providersBuilder;

  PBPageRoute({
    required this.name,
    String? path,
    required this.builder,
    this.parentNavigatorKey,
    this.providersBuilder,
    this.skipper,
  }) : _path = path ?? name;

  String get path => _path;
}

class PBTabRouteItem extends Equatable {
  final IRoute baseRoute;
  final String name;
  final IconData iconData;
  final GlobalKey<NavigatorState> navigatorKey;
  final List<Object> cubitsTypes;

  const PBTabRouteItem({
    required this.baseRoute,
    required this.name,
    required this.iconData,
    required this.navigatorKey,
    List<Object> cubits = const [],
  }) : cubitsTypes = cubits;

  @override
  List<Object?> get props => [
        baseRoute,
        name,
        iconData,
        navigatorKey,
        cubitsTypes,
      ];
}
