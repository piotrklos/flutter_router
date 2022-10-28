import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app_router/interface/router.dart';
import '../../shared/shared_page.dart';

class InsightsPage extends StatelessWidget {
  static const String name = "insihgts";

  const InsightsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Insights"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Insights Tab"),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  useRootNavigator: true,
                );
              },
              child: const Text("Show alert (useRootNavigator = true)"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  useRootNavigator: false,
                );
              },
              child: const Text("Show alert (useRootNavigator = false)"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppNavigator.of(context)
                    .pushNamed(
                  SharedPage.name,
                  extra: SharedObject("Sample message from insights"),
                )
                    .then((value) {
                  if (value != null) {
                    print("Value from push: $value");
                  }
                });
              },
              child: const Text("Go to shared page"),
            ),
          ],
        ),
      ),
    );
  }
}
