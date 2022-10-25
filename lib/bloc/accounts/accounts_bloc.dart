import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../base_app_bloc.dart';
import 'accounts_state.dart';

@Injectable()
class AccountsCubit extends Cubit<AccountsState>
    with AppRouterBlocProvider<AccountsCubit> {
  AccountsCubit()
      : super(
          AccountsState(DateTime.now().toIso8601String()),
        );

  void changeMessage(String message) {
    emit(AccountsState(message));
  }
}
