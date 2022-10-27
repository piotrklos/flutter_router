import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../app_router/interface/app_router_bloc_provider.dart';
import 'accounts_state.dart';

@LazySingleton()
class AccountsCubit extends Cubit<AccountsState>
    with PBAppRouterBlocProvider<AccountsCubit> {
  AccountsCubit()
      : super(
          AccountsState(DateTime.now().toIso8601String()),
        );

  void changeMessage(String message) {
    emit(AccountsState(message));
  }
}
