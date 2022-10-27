import 'package:flutter/material.dart';

import '../../../app_router/interface/router.dart';

class MessagesPage extends StatelessWidget {
  static const name = "messages";

  const MessagesPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Messages Tab"),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppRouter.of(context).go(
                  "/more/settings",
                );
              },
              child: const Text("Go to Settings"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                PBAppRouter.of(context).go(
                  "/messages/details",
                );
              },
              child: const Text("Go to Details"),
            ),
          ],
        ),
      ),
    );
  }
}
