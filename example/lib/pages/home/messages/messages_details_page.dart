import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/details/details_bloc.dart';
import '../../../bloc/details/details_state.dart';
import '../../../bloc/messages/messages_bloc.dart';
import '../../../bloc/messages/messages_state.dart';
import '../../../bloc/messages_details/messages_details_bloc.dart';
import '../../../bloc/messages_details/messages_details_state.dart';
import '../../../di/di.dart';

class MessagesDetailsPage extends StatelessWidget {
  static const String name = "messagesDetails";

  const MessagesDetailsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Messages Details"),
      ),
      child: BlocProvider<MessagesDetailsCubit>(
        create: (context) => getIt.get<MessagesDetailsCubit>(),
        child: BlocBuilder<MessagesDetailsCubit, MessagesDetailsState>(
          builder: (context, detailsState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Details Page"),
                  const SizedBox(height: 16),
                  BlocBuilder<DetailsCubit, DetailsState>(
                    builder: (context, state) {
                      return Text("Details State: ${state.message}");
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<MessagesCubit, MessagesState>(
                    builder: (context, state) {
                      return Text(
                        "Message State: ${state.message}",
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Message Details State: ${detailsState.message}",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
