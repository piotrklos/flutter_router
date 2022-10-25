import 'package:equatable/equatable.dart';

class MessagesState extends Equatable {
  final String message;

  const MessagesState(this.message);

  @override
  List<Object?> get props => [message];
}
