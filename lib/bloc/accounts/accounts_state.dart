import 'package:equatable/equatable.dart';

class AccountsState extends Equatable {
  final String message;

  const AccountsState(this.message);

  @override
  List<Object?> get props => [message];
}
