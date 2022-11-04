import 'package:flutter/foundation.dart';

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
