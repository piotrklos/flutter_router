import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppRouterBlocProvider<T extends BlocBase> {
  BlocProvider<StateStreamableSource<Object?>> get blocProvider {
    return BlocProvider<T>.value(value: this as T);
  }

  Future<void> close();
}
