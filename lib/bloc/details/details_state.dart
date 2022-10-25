import 'package:equatable/equatable.dart';

class DetailsState extends Equatable {
  final String message;

  const DetailsState(this.message);

  @override
  List<Object?> get props => [message];
}
