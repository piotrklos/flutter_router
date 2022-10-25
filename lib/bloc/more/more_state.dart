import 'package:equatable/equatable.dart';

class MoreState extends Equatable {
  final String message;

  const MoreState(this.message);

  @override
  List<Object?> get props => [message];
}
