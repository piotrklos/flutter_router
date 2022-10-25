import 'package:flutter/material.dart';

import '../../../app_router/context_extension.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

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
                context.go(
                  "/more/settings",
                );
              },
              child: const Text("Go to Settings"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go(
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
