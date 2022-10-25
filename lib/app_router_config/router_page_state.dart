import '../app_router/app_router_page_state.dart';

class RouterPageState {
  final String? name;
  final String fullpath;
  final Object? extra;
  final Exception? exception;

  RouterPageState({
    required this.fullpath,
    this.name,
    this.extra,
    this.exception,
  });
}

extension AppRouterPageStateMapper on AppRouterPageState {
  RouterPageState mapToRouterPageState() {
    return RouterPageState(
      fullpath: fullpath,
      exception: exception,
      extra: extra,
      name: name,
    );
  }
}
