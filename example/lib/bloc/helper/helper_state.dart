import 'package:equatable/equatable.dart';

class HelperState extends Equatable {
  final String message;

  const HelperState(this.message);

  @override
  List<Object?> get props => [message];
}
