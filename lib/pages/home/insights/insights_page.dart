import 'package:flutter/material.dart';

import '../../../app_router/context_extension.dart';
import '../../shared/shared_page.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
      ),
      body: Center(
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
                context
                    .push(
                  "/shared",
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
