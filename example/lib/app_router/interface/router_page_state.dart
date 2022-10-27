class PBAppRouterPageState {
  final String? name;
  final String fullpath;
  final Object? extra;
  final Exception? exception;

  PBAppRouterPageState({
    required this.fullpath,
    this.name,
    this.extra,
    this.exception,
  });
}
