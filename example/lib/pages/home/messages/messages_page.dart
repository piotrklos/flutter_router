import 'package:example/pages/home/messages/messages_details_page.dart';
import 'package:example/pages/home/more/settings/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app_router/interface/router.dart';

class MessagesPage extends StatelessWidget {
  static const name = "messages";

  const MessagesPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Messages"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Messages Tab"),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppNavigator.of(context).goNamed(SettingsPage.name);
              },
              child: const Text("Go to Settings"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppNavigator.of(context).goNamed(MessagesDetailsPage.name);
              },
              child: const Text("Go to Details"),
            ),
          ],
        ),
      ),
    );
  }
}
