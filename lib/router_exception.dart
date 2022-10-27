class AppRouterException {
  final String message;

  AppRouterException(this.message);

  @override
  String toString() {
    return "AppRouterException: $message";
  }
}
