import 'package:app_router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PBAppRouterBlocProvider<T extends BlocBase>
    implements AppRouterBlocProvider<T> {
  @override
  BlocProvider<StateStreamableSource<Object?>> get blocProvider {
    return BlocProvider<T>.value(value: this as T);
  }
}
