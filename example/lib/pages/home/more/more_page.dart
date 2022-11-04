import 'package:example/pages/home/more/notification/notification_page.dart';
import 'package:example/pages/home/more/settings/settings_page.dart';
import 'package:example/pages/start/start_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../app_router/interface/router.dart';
import '../../../bloc/more/more_bloc.dart';
import '../../../bloc/more/more_state.dart';

class MorePage extends StatelessWidget {
  static const name = "more";

  const MorePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoreCubit, MoreState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text("More"),
          ),
          child: ListView(
            primary: true,
            children: [
              Container(
                height: 200,
                color: Colors.red,
              ),
              const Text(
                "More Tab",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "State: ${state.message}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  PBAppNavigator.of(context).goNamed(NotificationPage.name);
                },
                child: const Text("Notification"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  PBAppNavigator.of(context).goNamed(SettingsPage.name);
                },
                child: const Text("Settings"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  PBAppNavigator.of(context).goNamed(StartPage.name);
                  GetIt.instance.resetLazySingleton<MoreCubit>();
                },
                child: const Text("Log out"),
              ),
              Container(
                height: 200,
                color: Colors.red,
              ),
              Container(
                height: 200,
                color: Colors.yellow,
              ),
              Container(
                height: 200,
                color: Colors.green,
              ),
              Container(
                height: 200,
                color: Colors.black,
              ),
            ],
          ),
        );
      },
    );
  }
}
