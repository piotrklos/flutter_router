import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../app_router/interface/app_router_bloc_provider.dart';
import 'details_state.dart';

@LazySingleton()
class DetailsCubit extends Cubit<DetailsState>
    with PBAppRouterBlocProvider<DetailsCubit> {
  DetailsCubit()
      : super(
          DetailsState(DateTime.now().toIso8601String()),
        );

  void changeMessage(String message) {
    emit(DetailsState(message));
  }
}
