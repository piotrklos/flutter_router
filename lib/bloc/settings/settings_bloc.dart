import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../base_app_bloc.dart';
import '../more/more_bloc.dart';
import 'settings_state.dart';

@Injectable()
class SettingsCubit extends Cubit<SettingsState>
    with AppRouterBlocProvider<SettingsCubit> {
  final MoreCubit? _moreCubit;

  SettingsCubit(
    @factoryParam this._moreCubit,
  ) : super(
          SettingsState("Setting state ${DateTime.now().toIso8601String()}"),
        );

  void changeMessage(String message) {
    emit(SettingsState(message));
  }

  void changeMoreCubitMessage(String message) {
    _moreCubit?.changeMessage(message);
  }
}
