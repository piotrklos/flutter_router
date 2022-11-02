import 'package:example/pages/home/accounts/relationship/relationship_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_router/interface/router.dart';
import '../../service/user_service.dart';

class StartPage extends StatelessWidget {
  static const name = "start";
  const StartPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Login Page",
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Login To app"),
            const SizedBox(
              height: 16,
            ),
            TextButton(
              onPressed: () {
                UserService.isInternal = true;
                PBAppNavigator.of(context).pushNamed("shared");
                // PBAppNavigator.of(context).goNamed(RelationshipPage.name);
              },
              child: const Text("Login Internal user"),
            ),
            TextButton(
              onPressed: () {
                UserService.isInternal = false;
                PBAppNavigator.of(context).goNamed(RelationshipPage.name);
              },
              child: const Text("Login External user"),
            ),
          ],
        ),
      ),
    );
  }
}
