import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../base_app_bloc.dart';
import 'helper_state.dart';

@Injectable()
class HelperCubit extends Cubit<HelperState>
    with AppRouterBlocProvider<HelperCubit> {
  HelperCubit()
      : super(
          HelperState("Helper state ${DateTime.now().toIso8601String()}"),
        );

  void changeMessage(String message) {
    emit(HelperState(message));
  }
}
