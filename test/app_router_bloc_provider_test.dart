import 'package:app_router/app_router_bloc_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("blocProvider", () {
    final cubit = _SampleCubit();
    expect(cubit.blocProvider, const TypeMatcher<BlocProvider<_SampleCubit>>());
  });
}

class _CubitState {}

class _SampleCubit extends Cubit<_CubitState>
    with AppRouterBlocProvider<_SampleCubit> {
  _SampleCubit() : super(_CubitState());
}
