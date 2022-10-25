import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppRouteInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  final Listenable? _refreshListenable;

  AppRouteInformationProvider({
    required RouteInformation initialRouteInformation,
    Listenable? refreshListenable,
  })  : _refreshListenable = refreshListenable,
        _value = initialRouteInformation {
    _refreshListenable?.addListener(notifyListeners);
  }

  WidgetsBinding? get _binding => WidgetsBinding.instance;

  /// value
  RouteInformation _value;

  @override
  RouteInformation get value => _value;

  set value(RouteInformation other) {
    final bool shouldNotify =
        _value.location != other.location || _value.state != other.state;
    _value = other;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  void _setNewRouteInformation(RouteInformation routeInformation) {
    if (_value == routeInformation) {
      return;
    }
    _value = routeInformation;
    notifyListeners();
  }

  /// other
  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    _value = routeInformation;
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      _binding?.addObserver(this);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _binding?.removeObserver(this);
    }
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    assert(hasListeners);
    _setNewRouteInformation(routeInformation);
    return SynchronousFuture(true);
  }

  @override
  Future<bool> didPushRoute(String route) {
    assert(hasListeners);
    _setNewRouteInformation(RouteInformation(location: route));
    return SynchronousFuture(true);
  }

  @override
  void dispose() {
    if (hasListeners) {
      _binding?.removeObserver(this);
    }
    _refreshListenable?.removeListener(notifyListeners);
    super.dispose();
  }
}
