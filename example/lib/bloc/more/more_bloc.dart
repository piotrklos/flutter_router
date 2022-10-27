import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../app_router/interface/app_router_bloc_provider.dart';
import 'more_state.dart';

@Injectable()
class MoreCubit extends Cubit<MoreState>
    with PBAppRouterBlocProvider<MoreCubit> {
  MoreCubit()
      : super(
          MoreState("More state ${DateTime.now().toIso8601String()}"),
        );

  void changeMessage(String message) {
    print("changeMessage");
    emit(MoreState(message));
  }
}
