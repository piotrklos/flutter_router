// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../app_router/implementation/app_router_impl.dart' as _i10;
import '../app_router/interface/router.dart' as _i9;
import '../bloc/accounts/accounts_bloc.dart' as _i3;
import '../bloc/details/details_bloc.dart' as _i4;
import '../bloc/helper/helper_bloc.dart' as _i5;
import '../bloc/messages/messages_bloc.dart' as _i6;
import '../bloc/messages_details/messages_details_bloc.dart' as _i7;
import '../bloc/more/more_bloc.dart' as _i8;
import '../bloc/settings/settings_bloc.dart' as _i11;
import '../service/user_service.dart'
    as _i12; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.factory<_i3.AccountsCubit>(() => _i3.AccountsCubit());
  gh.factory<_i4.DetailsCubit>(() => _i4.DetailsCubit());
  gh.factory<_i5.HelperCubit>(() => _i5.HelperCubit());
  gh.factory<_i6.MessagesCubit>(() => _i6.MessagesCubit());
  gh.factory<_i7.MessagesDetailsCubit>(() => _i7.MessagesDetailsCubit());
  gh.factory<_i8.MoreCubit>(() => _i8.MoreCubit());
  gh.factory<_i9.PBAppRouter<Object>>(() => _i10.AppRotuerImplementation());
  gh.factoryParam<_i11.SettingsCubit, _i8.MoreCubit?, dynamic>(
      (_moreCubit, _) => _i11.SettingsCubit(_moreCubit));
  gh.factory<_i12.UserService>(() => _i12.UserService());
  return get;
}
