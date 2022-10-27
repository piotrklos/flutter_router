import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../app_router/interface/app_router_bloc_provider.dart';
import 'messages_state.dart';

@Injectable()
class MessagesCubit extends Cubit<MessagesState>
    with PBAppRouterBlocProvider<MessagesCubit> {
  MessagesCubit()
      : super(
          MessagesState(DateTime.now().toIso8601String()),
        );

  void changeMessage(String message) {
    emit(MessagesState(message));
  }
}
