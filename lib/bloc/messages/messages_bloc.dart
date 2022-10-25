import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../base_app_bloc.dart';
import 'messages_state.dart';

@Injectable()
class MessagesCubit extends Cubit<MessagesState>
    with AppRouterBlocProvider<MessagesCubit> {
  MessagesCubit()
      : super(
          MessagesState(DateTime.now().toIso8601String()),
        );

  void changeMessage(String message) {
    emit(MessagesState(message));
  }
}
