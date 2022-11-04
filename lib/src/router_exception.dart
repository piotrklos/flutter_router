class AppRouterException implements Exception {
  final String message;

  AppRouterException(this.message);

  @override
  String toString() {
    return "AppRouterException: $message";
  }
}
