import 'package:equatable/equatable.dart';

class AppRouterLocation extends Equatable {
  final String path;
  final String name;

  const AppRouterLocation({
    required this.path,
    required this.name,
  });

  const AppRouterLocation.empty()
      : name = "",
        path = "";

  @override
  List<Object?> get props => [path, name];
}
