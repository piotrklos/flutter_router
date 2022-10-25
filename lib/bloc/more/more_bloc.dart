import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../base_app_bloc.dart';
import 'more_state.dart';

@Injectable()
class MoreCubit extends Cubit<MoreState> with AppRouterBlocProvider<MoreCubit> {
  MoreCubit()
      : super(
          MoreState("More state ${DateTime.now().toIso8601String()}"),
        );

  void changeMessage(String message) {
    print("changeMessage");
    emit(MoreState(message));
  }
}
