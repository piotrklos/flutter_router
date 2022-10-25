import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../base_app_bloc.dart';
import 'details_state.dart';

@Injectable()
class DetailsCubit extends Cubit<DetailsState>
    with AppRouterBlocProvider<DetailsCubit> {
  DetailsCubit()
      : super(
          DetailsState(DateTime.now().toIso8601String()),
        );

  void changeMessage(String message) {
    emit(DetailsState(message));
  }
}
