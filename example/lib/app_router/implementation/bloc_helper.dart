import 'package:get_it/get_it.dart';

import '../../bloc/accounts/accounts_bloc.dart';
import '../../bloc/details/details_bloc.dart';
import '../../bloc/helper/helper_bloc.dart';
import '../../bloc/messages/messages_bloc.dart';
import '../../bloc/more/more_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../interface/app_router_bloc_provider.dart';

class BlocHelper {
  static PBAppRouterBlocProvider getBlocByType<T extends Object>(T type) {
    // with custom getIt
    // return getIt.getWithType(type: type);
    // return GetIt.instance.get<T>() as AppRouterBlocProvider;
    if (type == HelperCubit) {
      return GetIt.instance.get<HelperCubit>();
    } else if (type == MessagesCubit) {
      return GetIt.instance.get<MessagesCubit>();
    } else if (type == MoreCubit) {
      return GetIt.instance.get<MoreCubit>();
    } else if (type == SettingsCubit) {
      return GetIt.instance.get<SettingsCubit>();
    } else if (type == AccountsCubit) {
      return GetIt.instance.get<AccountsCubit>();
    } else if (type == DetailsCubit) {
      return GetIt.instance.get<DetailsCubit>();
    }
    throw Exception("Type $type not registrated");
  }
}
