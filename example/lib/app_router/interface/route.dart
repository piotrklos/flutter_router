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

  String get name {
    if (this is PBPageRoute) {
      return (this as PBPageRoute)._name;
    }
    return "";
  }
}

class PBTabRoute extends IRoute {
  final List<PBTabRouteItem> items;

  PBTabRoute({
    required this.items,
  });

  void dispose() {
    for (var item in items) {
      item.onDispose?.call();
    }
  }
}

class PBPageRoute extends IRoute {
  final String _name;
  final String _path;
  final PBAppRouteWidgetBuilder builder;
  final PBAppRouteSkipper? skipper;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final List<PBAppRouterBlocProvider> Function(
    PBCubitGetter cubitGetter,
  )? providersBuilder;

  PBPageRoute({
    required String name,
    String? path,
    required this.builder,
    this.parentNavigatorKey,
    this.providersBuilder,
    this.skipper,
  })  : _path = path ?? name,
        _name = name;

  String get path => _path;
}

class PBTabRouteItem extends Equatable {
  final IRoute baseRoute;
  final String name;
  final IconData iconData;
  final GlobalKey<NavigatorState> navigatorKey;
  final ValueGetter<List<PBAppRouterBlocProvider>>? blocsGetter;
  final VoidCallback? onDispose;

  const PBTabRouteItem({
    required this.baseRoute,
    required this.name,
    required this.iconData,
    required this.navigatorKey,
    this.blocsGetter,
    this.onDispose,
  });

  @override
  List<Object?> get props => [
        baseRoute,
        name,
        iconData,
        navigatorKey,
        blocsGetter,
      ];
}
