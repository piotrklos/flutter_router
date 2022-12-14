import 'package:flutter/material.dart';


class SharedObject {
  final String message;

  SharedObject(this.message);
}

class SharedPage extends StatelessWidget {
  final SharedObject? sharedObject;

  const SharedPage({
    required this.sharedObject,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shared"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Share Page"),
            const SizedBox(height: 16),
            Text(sharedObject?.message ?? "-----"),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop("test");
                // AppRouter.of(context).pop("Przyklad");
              },
              child: const Text("Pop"),
            ),
          ],
        ),
      ),
    );
  }
}
