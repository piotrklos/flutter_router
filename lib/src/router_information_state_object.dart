import 'dart:async';

import 'package:equatable/equatable.dart';

import 'route_finder.dart';

class RouterInformationStateObject<T extends Object?> extends Equatable {
  final Object? extra;
  final bool backToCaller;
  final RouterPaths? parentStack;
  final Completer<T> completer;

  const RouterInformationStateObject({
    required this.extra,
    required this.backToCaller,
    required this.parentStack,
    required this.completer,
  });

  @override
  List<Object?> get props => [
        extra,
        backToCaller,
        parentStack,
        completer,
      ];
}
