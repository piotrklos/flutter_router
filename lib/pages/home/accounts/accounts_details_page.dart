import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/details/details_state.dart';
import '../../../bloc/accounts/accounts_bloc.dart';
import '../../../bloc/accounts/accounts_state.dart';
import '../../../bloc/details/details_bloc.dart';

class AccountsDetailsPage extends StatelessWidget {
  const AccountsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts Details"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Details Page"),
            const SizedBox(height: 16),
            BlocBuilder<DetailsCubit, DetailsState>(
              builder: (context, state) {
                return Text("Details State: ${state.message}");
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<AccountsCubit, AccountsState>(
              builder: (context, state) {
                return Text(
                  "Accounts State: ${state.message}",
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
