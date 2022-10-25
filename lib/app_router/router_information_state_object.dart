import 'dart:async';

import 'route_finder.dart';

class RouterInformationStateObject<T extends Object?> {
  final Object? extra;
  final bool backToParent;
  final RouterPaths? parentStack;
  final Completer<T> completer;

  RouterInformationStateObject({
    required this.extra,
    required this.backToParent,
    required this.parentStack,
    required this.completer,
  });
}
