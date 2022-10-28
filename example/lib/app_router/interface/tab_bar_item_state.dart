import 'location.dart';

class PBTabBarItemState {
  final PBRouteLocation currentLocation;
  final PBRouteLocation rootRouteLocation;

  PBTabBarItemState({
    required this.currentLocation,
    required this.rootRouteLocation,
  });
}