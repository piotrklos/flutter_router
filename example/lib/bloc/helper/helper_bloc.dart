import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../app_router/interface/app_router_bloc_provider.dart';
import 'helper_state.dart';

@Injectable()
class HelperCubit extends Cubit<HelperState>
    with PBAppRouterBlocProvider<HelperCubit> {
  HelperCubit()
      : super(
          HelperState("Helper state ${DateTime.now().toIso8601String()}"),
        );

  void changeMessage(String message) {
    emit(HelperState(message));
  }
}
