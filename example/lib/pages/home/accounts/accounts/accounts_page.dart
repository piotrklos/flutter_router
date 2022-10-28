import 'package:example/app_router/interface/router.dart';
import 'package:example/pages/home/accounts/accounts_details_page.dart';
import 'package:example/pages/home/messages/messages_details_page.dart';
import 'package:example/pages/home/more/more_page.dart';
import 'package:example/pages/home/more/settings/helper/helper_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/details/details_bloc.dart';

class AccountsPage extends StatelessWidget {
  static const String name = "accounts";
  final String? familyName;

  const AccountsPage({
    required this.familyName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accounts: ${familyName ?? "---"}"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Accounts Tab"),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppNavigator.of(context).goNamed(AccountsDetailsPage.name);
              },
              child: const Text("Go to Details"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppNavigator.of(context).goNamed(MessagesDetailsPage.name);
              },
              child: const Text("Go to Message Details Page"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppNavigator.of(context).goNamed(MorePage.name);
              },
              child: const Text("Go to More Page"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppNavigator.of(context)
                    .goNamed(
                  HelperPage.name,
                  backToParent: true,
                  extra: "Hello from accounts",
                )
                    .then((value) {
                  print("value $value");
                });
              },
              child: const Text("Go to More Helper Page"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _showSetValueDialog(context);
              },
              child: const Text("Set new value to details cubit"),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetValueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      context.read<DetailsCubit>().changeMessage(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
