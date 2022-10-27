import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'messages_details_state.dart';

@Injectable()
class MessagesDetailsCubit extends Cubit<MessagesDetailsState> {
  MessagesDetailsCubit()
      : super(
          MessagesDetailsState(
            "Hello from Details Message Cubit: ${DateTime.now().toIso8601String()}",
          ),
        );

  void changeMessage(String message) {
    emit(MessagesDetailsState(message));
  }
}
