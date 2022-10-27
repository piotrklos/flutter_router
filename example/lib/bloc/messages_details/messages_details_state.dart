import 'package:equatable/equatable.dart';

class MessagesDetailsState extends Equatable {
  final String message;

  const MessagesDetailsState(this.message);

  @override
  List<Object?> get props => [message];
}
