import 'package:flutter_bloc/flutter_bloc.dart';

mixin AppRouterBlocProvider<T extends Cubit> {
  BlocProvider<StateStreamableSource<Object?>> get blocProvider {
    return BlocProvider<T>.value(value: this as T);
  }
}
