import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String message;

  const SettingsState(this.message);

  @override
  List<Object?> get props => [message];
}
